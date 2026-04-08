Input = {}

function Input.MousePosGlobal()
    local x, y = love.mouse.getPosition()
    x, y = love.graphics.inverseTransformPoint(x, y)
    return x, y
end

return Input