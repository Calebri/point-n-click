--[[
    Class: Item
]]

Object = require "lib.classic"

Item = Object:extend()

---@param id string
---@param img? Image
function Item.new(self, id, img)
    self.id = id
    self.img = img or love.graphics.newImage()
end

return Item