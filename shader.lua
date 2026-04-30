Shader = {}

Shader.pixelBlur = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        // Based on https://www.shadertoy.com/view/MtdXDM

        //number transitionFactor = 0.1; // Number from 0 - 1
        //number maxPixelSize = 10;
        number pixelSize = 20; // maxPixelSize * transitionFactor;
        vec2 resolution = Vec2(650, 490);
    
        vec2 finalUV = texture_coords;

        finalUV *= resolution; // Convert to 0..resolution UV space
        finalUV /= pixelSize;
        finalUV = floor(finalUV);
        finalUV *= pixelSize;
        finalUV /= resolution; // Convert back to 0..1 UV space

        vec4 texturecolor = Texel(tex, finalUV);
        return texturecolor * color;
    }
]])

return Shader