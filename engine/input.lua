--[[
    Module: Input
    Helper module that returns commonly used user input methods.
]]

Input = {}

---Returns mouse position in global coordinates.
---@return number x, number y: Mouse position in global coordinates
function Input.MousePosGlobal()
    local x, y = love.mouse.getPosition()
    x, y = love.graphics.inverseTransformPoint(x, y)
    return x, y
end

return Input