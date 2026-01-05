//
//  Pixelate.metal
//  LanguageFlag
//
//  Metal shader for pixelation effect
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                              constant float2 *positions [[buffer(0)]],
                              constant float2 *texCoords [[buffer(1)]]) {
    VertexOut out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.texCoord = texCoords[vertexID];
    return out;
}

fragment float4 pixelateFragment(VertexOut in [[stage_in]],
                                  texture2d<float> sourceTexture [[texture(0)]],
                                  constant float &pixelSize [[buffer(0)]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);

    // Get texture dimensions
    float2 textureSize = float2(sourceTexture.get_width(), sourceTexture.get_height());

    // Calculate pixelated coordinates
    float2 pixelatedCoord = floor(in.texCoord * textureSize / pixelSize) * pixelSize / textureSize;

    // Sample the texture at the pixelated coordinate
    float4 color = sourceTexture.sample(textureSampler, pixelatedCoord);

    return color;
}
