Window = {}

Window.width = 256 --1920
Window.height = 224 --1080

Window.ratio = Window.width / Window.height

function Window.draw()
    local s = love.graphics.getHeight() / Window.height
    love.graphics.scale(s, s)
    love.graphics.translate((love.graphics.getWidth() - love.graphics.getHeight() * Window.ratio) / (2 * s), 0)
end

return Window
