--[[
    Class: Addon
    Used for any visual in a scene that needs to be dynamically visible.

    Image img: Image to draw
    boolean active: Whether the Addon should be drawn
]]

Addon = Object:extend()

function Addon.new(self, img, active)
    self.img = assert(img)
    self.active = active
end

function Addon.draw(self)
    love.graphics.draw(self.img)
end
return Addon