//
//  Hologram.ci.metal
//  LanguageFlag
//
//  Metal-based hologram shader for Core Image
//

#include <CoreImage/CoreImage.h>

extern "C" {
    namespace coreimage {
        float4 hologramKernel(sample_t s, float time, float strength, destination dest) {
            float4 original = s;
            
            // 1. Scanlines - horizontal lines moving vertically
            float yPos = dest.coord().y;
            float scanline = sin(yPos * 0.3 + time * 10.0) * 0.5 + 0.5;
            scanline = pow(scanline, 2.0);
            
            // 2. RGB Split / Chromatic Aberration
            float offset = strength * 2.0;
            float4 color = original;
            
            // Offset red and blue channels slightly
            color.r = original.r + sin(time + yPos * 0.1) * offset * 0.1;
            color.b = original.b - cos(time + yPos * 0.1) * offset * 0.1;
            
            // 3. Cyan/Blue hologram tint
            float3 hologramTint = float3(0.3, 0.8, 1.0); // Cyan-blue color
            color.rgb = mix(original.rgb, original.rgb * hologramTint, strength * 0.6);
            
            // 4. Add scanline brightness variation
            float scanlineEffect = scanline * 0.4 * strength;
            color.rgb += float3(scanlineEffect * 0.3, scanlineEffect * 0.6, scanlineEffect * 1.0);
            
            // 5. Flickering / Glitching transparency
            float flicker = sin(time * 30.0 + yPos * 0.5) * 0.5 + 0.5;
            flicker = pow(flicker, 5.0); // Make it more sporadic
            float alphaVariation = 1.0 - (flicker * 0.15 * strength);
            
            // 6. Edge glow effect
            float edgeGlow = abs(sin(yPos * 0.15 + time * 5.0));
            color.rgb += float3(0.0, 0.3, 0.5) * edgeGlow * strength * 0.3;
            
            return float4(color.rgb, original.a * alphaVariation);
        }
    }
}
