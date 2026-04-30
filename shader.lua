Shader = {}

Shader.pixelBlur = love.graphics.newShader([[
    extern number transitionFactor; // Number from 0 - 1

    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        // Based on https://www.shadertoy.com/view/MtdXDM

        number minPixelSize = 1;
        number maxPixelSize = 100;

        number pixelSize = mix(minPixelSize, maxPixelSize, transitionFactor);

        vec2 resolution = vec2(650, 490);
        vec2 center = vec2(0.5);
    
        vec2 finalUV = texture_coords;

        finalUV -= center;
        finalUV *= resolution; // Convert to 0..resolution UV space
        finalUV /= pixelSize;
        finalUV = floor(finalUV);
        finalUV *= pixelSize;
        finalUV /= resolution; // Convert back to 0..1 UV space
        finalUV += center;

        vec4 texturecolor = Texel(tex, finalUV);
        return texturecolor * color;
    }
]])

return Shader