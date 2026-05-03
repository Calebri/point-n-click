--[[
    Class: Addon
    Used for any visual in a scene that needs to be dynamically visible.

    Image img: Image to draw
    boolean active: Whether the Addon should be drawn
]]

Addon = Object:extend()

---comment
---@param self table
---@param img Image
---@param activeCondition? table
function Addon.new(self, img, activeCondition)
    self.img = assert(img)

    if activeCondition then
        if activeCondition["active"] then
            self.active = activeCondition["active"]
        end

        if activeCondition["flags"] then
            self.active = false
            self.flags = activeCondition["flags"]
        end
    else
        self.active = true
    end
end

function Addon.draw(self)
    if self.active then
        love.graphics.draw(self.img)
    end
end
return Addon