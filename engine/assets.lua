--[[
    Module: Assets
    Helper module for loading game assets in predefined formats.
]]

Assets = {}

---Returns a formatted image located at a given path.
---@param path string Path to the image in the local filesystem.
---@return love.graphics.Image image Formatted image at path
function Assets.GetImg(path)
    local img = love.graphics.newImage(path)
    img:setFilter("nearest", "nearest")
    return img
end

return Assets