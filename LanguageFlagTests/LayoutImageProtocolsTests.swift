import Testing
import Foundation
import AppKit
@testable import LanguageFlag

/// Test suite for Layout Image Protocol implementations
@Suite("Layout Image Protocols Tests")
struct LayoutImageProtocolsTests {
    
    // MARK: - JSON Layout Mapping Provider Tests
    
    @Suite("JSON Layout Mapping")
    struct JSONLayoutMappingTests {
        
        @Test("Load valid layout mapping")
        func testLoadValidMapping() async throws {
            // This test assumes Layout.json exists in the test bundle
            let provider = JSONLayoutMappingProvider()
            
            // Test with a common layout that should exist
            do {
                let imageName = try provider.imageName(for: "U.S.")
                #expect(!imageName.isEmpty, "Image name should not be empty for valid layout")
            } catch {
                Issue.record("Failed to load valid layout mapping: \(error)")
            }
        }
        
        @Test("Throw error for unknown layout")
        func testUnknownLayoutThrowsError() async throws {
            let provider = JSONLayoutMappingProvider()
            
            do {
                _ = try provider.imageName(for: "NonExistentLayout_12345")
                Issue.record("Should have thrown error for unknown layout")
            } catch LayoutImageError.layoutNotFound(let layout) {
                #expect(layout == "NonExistentLayout_12345", "Error should contain the missing layout name")
            } catch {
                Issue.record("Unexpected error type: \(error)")
            }
        }
        
        @Test("Handle Layout.json not found", .disabled("Requires custom test bundle configuration"))
        func testMissingJSONFile() async throws {
            // TODO: This would require injecting a custom bundle or file path
            // to test the error case when Layout.json is missing
        }
        
        @Test("Handle corrupted JSON", .disabled("Requires custom test bundle configuration"))
        func testCorruptedJSON() async throws {
            // TODO: This would require injecting corrupted JSON data
            // to test the parsing error case
        }
    }
    
    // MARK: - Image Caching Tests
    
    @Suite("NSCache Image Caching")
    struct ImageCachingTests {
        
        @Test("Cache and retrieve image")
        func testCacheAndRetrieve() async throws {
            let cache = NSCacheImageCache()
            let testImage = NSImage(size: NSSize(width: 24, height: 24), flipped: false) { _ in true }
            let cacheKey = "test_layout_US"
            
            // Cache the image
            cache.cache(testImage, for: cacheKey)
            
            // Retrieve the image
            let retrieved = cache.cachedImage(for: cacheKey)
            #expect(retrieved != nil, "Cached image should be retrievable")
            #expect(retrieved === testImage, "Retrieved image should be the same instance")
        }
        
        @Test("Cache miss returns nil")
        func testCacheMiss() async throws {
            let cache = NSCacheImageCache()
            
            let retrieved = cache.cachedImage(for: "nonexistent_key")
            #expect(retrieved == nil, "Cache miss should return nil")
        }
        
        @Test("Cache overwrites existing entry")
        func testCacheOverwrite() async throws {
            let cache = NSCacheImageCache()
            let cacheKey = "test_layout"
            
            let image1 = NSImage(size: NSSize(width: 24, height: 24), flipped: false) { _ in true }
            let image2 = NSImage(size: NSSize(width: 32, height: 32), flipped: false) { _ in true }
            
            // Cache first image
            cache.cache(image1, for: cacheKey)
            
            // Cache second image with same key
            cache.cache(image2, for: cacheKey)
            
            // Retrieve should get the second image
            let retrieved = cache.cachedImage(for: cacheKey)
            #expect(retrieved === image2, "Should retrieve the most recently cached image")
        }
        
        @Test("Cache handles multiple keys")
        func testMultipleKeys() async throws {
            let cache = NSCacheImageCache()
            
            let image1 = NSImage(size: NSSize(width: 24, height: 24), flipped: false) { _ in true }
            let image2 = NSImage(size: NSSize(width: 24, height: 24), flipped: false) { _ in true }
            
            cache.cache(image1, for: "key1")
            cache.cache(image2, for: "key2")
            
            let retrieved1 = cache.cachedImage(for: "key1")
            let retrieved2 = cache.cachedImage(for: "key2")
            
            #expect(retrieved1 === image1, "Should retrieve correct image for key1")
            #expect(retrieved2 === image2, "Should retrieve correct image for key2")
        }
    }
    
    // MARK: - Image Rendering Tests
    
    @Suite("Flag Image Rendering")
    struct ImageRenderingTests {
        
        @Test("Render image with correct size")
        func testRenderCorrectSize() async throws {
            let renderer = FlagImageRenderer()
            let baseImage = NSImage(size: NSSize(width: 100, height: 100), flipped: false) { _ in true }
            let targetSize = NSSize(width: 24, height: 24)
            
            let rendered = renderer.renderImage(baseImage, size: targetSize, withCapsLock: false)
            
            #expect(rendered.size.width == targetSize.width, "Rendered width should match target")
            #expect(rendered.size.height == targetSize.height, "Rendered height should match target")
        }
        
        @Test("Render image without Caps Lock indicator")
        func testRenderWithoutCapsLock() async throws {
            let renderer = FlagImageRenderer()
            let baseImage = NSImage(size: NSSize(width: 100, height: 100), flipped: false) { rect in
                // Draw a simple red rectangle as test content
                NSColor.red.setFill()
                rect.fill()
                return true
            }
            let targetSize = NSSize(width: 24, height: 24)
            
            let rendered = renderer.renderImage(baseImage, size: targetSize, withCapsLock: false)
            
            #expect(rendered.size == targetSize, "Rendered image should have correct size")
            // Note: Visual validation of no Caps Lock indicator would require more complex testing
        }
        
        @Test("Render image with Caps Lock indicator")
        func testRenderWithCapsLock() async throws {
            let renderer = FlagImageRenderer()
            let baseImage = NSImage(size: NSSize(width: 100, height: 100), flipped: false) { rect in
                NSColor.blue.setFill()
                rect.fill()
                return true
            }
            let targetSize = NSSize(width: 24, height: 24)
            
            let rendered = renderer.renderImage(baseImage, size: targetSize, withCapsLock: true)
            
            #expect(rendered.size == targetSize, "Rendered image should have correct size")
            // Note: Caps Lock indicator presence would require pixel-level inspection
        }
        
        @Test("Async rendering completes successfully")
        func testAsyncRendering() async throws {
            let renderer = FlagImageRenderer()
            let baseImage = NSImage(size: NSSize(width: 100, height: 100), flipped: false) { _ in true }
            let targetSize = NSSize(width: 24, height: 24)
            
            let rendered = await renderer.renderImageAsync(baseImage, size: targetSize, withCapsLock: false)
            
            #expect(rendered.size == targetSize, "Async rendered image should have correct size")
        }
        
        @Test("Async rendering matches sync rendering")
        func testAsyncMatchesSync() async throws {
            let renderer = FlagImageRenderer()
            let baseImage = NSImage(size: NSSize(width: 100, height: 100), flipped: false) { rect in
                NSColor.green.setFill()
                rect.fill()
                return true
            }
            let targetSize = NSSize(width: 32, height: 32)
            
            let syncRendered = renderer.renderImage(baseImage, size: targetSize, withCapsLock: true)
            let asyncRendered = await renderer.renderImageAsync(baseImage, size: targetSize, withCapsLock: true)
            
            #expect(syncRendered.size == asyncRendered.size, "Sync and async rendering should produce same size")
        }
        
        @Test("Render with different sizes")
        func testRenderDifferentSizes() async throws {
            let renderer = FlagImageRenderer()
            let baseImage = NSImage(size: NSSize(width: 100, height: 100), flipped: false) { _ in true }
            
            let sizes = [
                NSSize(width: 16, height: 16),
                NSSize(width: 24, height: 24),
                NSSize(width: 32, height: 32),
                NSSize(width: 48, height: 48)
            ]
            
            for size in sizes {
                let rendered = renderer.renderImage(baseImage, size: size, withCapsLock: false)
                #expect(rendered.size == size, "Rendered image should match requested size \(size)")
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    @Suite("Error Handling")
    struct ErrorHandlingTests {
        
        @Test("LayoutImageError descriptions are informative")
        func testErrorDescriptions() async throws {
            let errors: [LayoutImageError] = [
                .layoutNotFound("TestLayout"),
                .imageNotFound("TestImage"),
                .jsonParsingFailed(NSError(domain: "Test", code: 1)),
                .jsonFileNotFound
            ]
            
            for error in errors {
                let description = error.errorDescription
                #expect(description != nil, "Error should have a description")
                #expect(!description!.isEmpty, "Error description should not be empty")
            }
        }
        
        @Test("Layout not found error contains layout name")
        func testLayoutNotFoundError() async throws {
            let layoutName = "MyCustomLayout"
            let error = LayoutImageError.layoutNotFound(layoutName)
            
            #expect(error.errorDescription?.contains(layoutName) == true, "Error should mention the layout name")
        }
        
        @Test("Image not found error contains image name")
        func testImageNotFoundError() async throws {
            let imageName = "flag_us"
            let error = LayoutImageError.imageNotFound(imageName)
            
            #expect(error.errorDescription?.contains(imageName) == true, "Error should mention the image name")
        }
    }
}
