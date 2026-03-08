import Testing
import Foundation
import CoreGraphics
@testable import LanguageFlag

@Suite("WindowPositionCalculator Tests")
struct WindowPositionCalculatorTests {

    // Screen: 1000x800 at origin (0,0)
    // horizontalPadding = min(50, 1000*0.05) = 50
    // verticalPadding   = min(50,  800*0.05) = 40
    private let screen = CGRect(x: 0, y: 0, width: 1000, height: 800)
    private let sut = WindowPositionCalculator()

    // MARK: - Frame Calculation — Corners

    @Test("topLeft frame is top-left with padding")
    func testTopLeftFrame() {
        let frame = sut.calculateWindowFrame(in: screen, position: .topLeft, size: .small)
        let d = WindowSize.small.dimensions
        #expect(frame.origin.x == screen.minX + 50)
        #expect(frame.origin.y == screen.maxY - d.height - 40)
        #expect(frame.width == d.width)
        #expect(frame.height == d.height)
    }

    @Test("topRight frame is top-right with padding")
    func testTopRightFrame() {
        let frame = sut.calculateWindowFrame(in: screen, position: .topRight, size: .small)
        let d = WindowSize.small.dimensions
        #expect(frame.origin.x == screen.maxX - d.width - 50)
        #expect(frame.origin.y == screen.maxY - d.height - 40)
    }

    @Test("bottomLeft frame is bottom-left with padding")
    func testBottomLeftFrame() {
        let frame = sut.calculateWindowFrame(in: screen, position: .bottomLeft, size: .small)
        #expect(frame.origin.x == screen.minX + 50)
        #expect(frame.origin.y == screen.minY + 40)
    }

    @Test("bottomRight frame is bottom-right with padding")
    func testBottomRightFrame() {
        let frame = sut.calculateWindowFrame(in: screen, position: .bottomRight, size: .small)
        let d = WindowSize.small.dimensions
        #expect(frame.origin.x == screen.maxX - d.width - 50)
        #expect(frame.origin.y == screen.minY + 40)
    }

    // MARK: - Frame Calculation — Centers

    @Test("topCenter frame is horizontally centered")
    func testTopCenterFrame() {
        let frame = sut.calculateWindowFrame(in: screen, position: .topCenter, size: .small)
        let d = WindowSize.small.dimensions
        #expect(frame.origin.x == (screen.width - d.width) / 2)
        #expect(frame.origin.y == screen.maxY - d.height - 40)
    }

    @Test("bottomCenter frame is horizontally centered")
    func testBottomCenterFrame() {
        let frame = sut.calculateWindowFrame(in: screen, position: .bottomCenter, size: .small)
        let d = WindowSize.small.dimensions
        #expect(frame.origin.x == (screen.width - d.width) / 2)
        #expect(frame.origin.y == screen.minY + 40)
    }

    @Test("center frame is fully centered")
    func testCenterFrame() {
        let frame = sut.calculateWindowFrame(in: screen, position: .center, size: .small)
        let d = WindowSize.small.dimensions
        #expect(frame.origin.x == (screen.width - d.width) / 2)
        #expect(frame.origin.y == (screen.height - d.height) / 2)
    }

    @Test("centerLeft frame is vertically centered on left")
    func testCenterLeftFrame() {
        let frame = sut.calculateWindowFrame(in: screen, position: .centerLeft, size: .small)
        let d = WindowSize.small.dimensions
        #expect(frame.origin.x == screen.minX + 50)
        #expect(frame.origin.y == (screen.height - d.height) / 2)
    }

    @Test("centerRight frame is vertically centered on right")
    func testCenterRightFrame() {
        let frame = sut.calculateWindowFrame(in: screen, position: .centerRight, size: .small)
        let d = WindowSize.small.dimensions
        #expect(frame.origin.x == screen.maxX - d.width - 50)
        #expect(frame.origin.y == (screen.height - d.height) / 2)
    }

    // MARK: - Frame Calculation — All Window Sizes

    @Test("frame dimensions match window size")
    func testFrameDimensionsMatchSize() {
        for size in WindowSize.allCases {
            let frame = sut.calculateWindowFrame(in: screen, position: .center, size: size)
            #expect(frame.width == size.dimensions.width)
            #expect(frame.height == size.dimensions.height)
        }
    }

    // MARK: - Padding Clamps at 50

    @Test("horizontal padding clamps to 50 on wide screen")
    func testHorizontalPaddingClamps() {
        // 5% of 2000 = 100 → clamped to 50
        let wideScreen = CGRect(x: 0, y: 0, width: 2000, height: 800)
        let frame = sut.calculateWindowFrame(in: wideScreen, position: .topLeft, size: .small)
        #expect(frame.origin.x == 50)
    }

    @Test("vertical padding clamps to 50 on tall screen")
    func testVerticalPaddingClamps() {
        // 5% of 2000 = 100 → clamped to 50
        let tallScreen = CGRect(x: 0, y: 0, width: 1000, height: 2000)
        let d = WindowSize.small.dimensions
        let frame = sut.calculateWindowFrame(in: tallScreen, position: .topLeft, size: .small)
        #expect(frame.origin.y == 2000 - d.height - 50)
    }

    // MARK: - Slide Direction

    @Test("slide direction is up when window is near top edge")
    func testSlideDirectionUp() {
        // minY=700, maxY=750 → distanceToTop=50, bottom=700, left=100, right=800
        let windowFrame = CGRect(x: 100, y: 700, width: 100, height: 50)
        let direction = sut.slideDirection(for: windowFrame, in: screen)
        #expect(direction == .up)
    }

    @Test("slide direction is down when window is near bottom edge")
    func testSlideDirectionDown() {
        // minY=10 → distanceToBottom=10
        let windowFrame = CGRect(x: 400, y: 10, width: 100, height: 50)
        let direction = sut.slideDirection(for: windowFrame, in: screen)
        #expect(direction == .down)
    }

    @Test("slide direction is left when window is near left edge")
    func testSlideDirectionLeft() {
        // minX=5 → distanceToLeft=5
        let windowFrame = CGRect(x: 5, y: 300, width: 100, height: 50)
        let direction = sut.slideDirection(for: windowFrame, in: screen)
        #expect(direction == .left)
    }

    @Test("slide direction is right when window is near right edge")
    func testSlideDirectionRight() {
        // maxX=990, distanceToRight=10
        let windowFrame = CGRect(x: 890, y: 300, width: 100, height: 50)
        let direction = sut.slideDirection(for: windowFrame, in: screen)
        #expect(direction == .right)
    }

    // MARK: - Max Slide Distance

    @Test("maxSlideDistance up equals window height when flush to top")
    func testMaxSlideDistanceUpFlush() {
        // windowFrame.maxY == screen.maxY → distanceToEdge=0, baseDistance=0, extra=0
        let windowFrame = CGRect(x: 0, y: 750, width: 100, height: 50)
        let distance = sut.maxSlideDistance(for: .up, windowFrame: windowFrame, screenRect: screen)
        #expect(distance == 0)
    }

    @Test("maxSlideDistance up equals distanceToEdge when smaller than window height")
    func testMaxSlideDistanceUpSmall() {
        // distanceToEdge=30, windowHeight=50 → baseDistance=min(30,50)=30, extra=0
        let windowFrame = CGRect(x: 0, y: 720, width: 100, height: 50)
        let distance = sut.maxSlideDistance(for: .up, windowFrame: windowFrame, screenRect: screen)
        #expect(distance == 30)
    }

    @Test("maxSlideDistance up adds up to 50 extra when gap exceeds window height")
    func testMaxSlideDistanceUpWithExtra() {
        // windowFrame: y=500, height=50, maxY=550
        // distanceToEdge = 800-550 = 250
        // baseDistance = min(250,50) = 50
        // extraDistance = max(0,250-50) = 200 → clamped to 50
        // result = 50 + 50 = 100
        let windowFrame = CGRect(x: 0, y: 500, width: 100, height: 50)
        let distance = sut.maxSlideDistance(for: .up, windowFrame: windowFrame, screenRect: screen)
        #expect(distance == 100)
    }

    @Test("maxSlideDistance down mirrors up logic")
    func testMaxSlideDistanceDown() {
        // windowFrame: y=30, height=50
        // distanceToEdge = 30-0 = 30
        // baseDistance = min(30,50) = 30, extra=0
        let windowFrame = CGRect(x: 0, y: 30, width: 100, height: 50)
        let distance = sut.maxSlideDistance(for: .down, windowFrame: windowFrame, screenRect: screen)
        #expect(distance == 30)
    }

    @Test("maxSlideDistance left equals distanceToEdge when smaller than window width")
    func testMaxSlideDistanceLeft() {
        // minX=20 → distanceToEdge=20, width=100 → baseDistance=20, extra=0
        let windowFrame = CGRect(x: 20, y: 400, width: 100, height: 50)
        let distance = sut.maxSlideDistance(for: .left, windowFrame: windowFrame, screenRect: screen)
        #expect(distance == 20)
    }

    @Test("maxSlideDistance right equals distanceToEdge when smaller than window width")
    func testMaxSlideDistanceRight() {
        // maxX = 980, distanceToEdge = 1000-980 = 20
        let windowFrame = CGRect(x: 880, y: 400, width: 100, height: 50)
        let distance = sut.maxSlideDistance(for: .right, windowFrame: windowFrame, screenRect: screen)
        #expect(distance == 20)
    }

    @Test("maxSlideDistance extra is capped at 50")
    func testMaxSlideDistanceExtraIsCapped() {
        // very far from edge: y=0, height=50
        // distanceToEdge=800-50=750, baseDistance=min(750,50)=50, extra=min(700,50)=50
        // result = 50+50 = 100
        let windowFrame = CGRect(x: 0, y: 0, width: 100, height: 50)
        let distance = sut.maxSlideDistance(for: .up, windowFrame: windowFrame, screenRect: screen)
        #expect(distance == 100)
    }
}
