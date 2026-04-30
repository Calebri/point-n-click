Shader = {}

Shader.pixelBlur = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        //number transitionFactor = 0.1; // Number from 0 - 1
        //number maxPixelSize = 10;
        number downscaleFactor = 20; // maxPixelSize * transitionFactor;
        number resolution = 650;
    
        vec2 finalUV = texture_coords;

        //if (downscaleFactor != 1) {
            finalUV *= resolution;
            finalUV /= downscaleFactor;
            finalUV = floor(finalUV);
            finalUV *= downscaleFactor;
            finalUV /= resolution;
        //}

        vec4 texturecolor = Texel(tex, finalUV);
        return texturecolor * color;
    }
]])

return Shader