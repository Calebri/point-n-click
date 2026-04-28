Window = {}

Window.width = 650 --1920
Window.height = 490 --1080

Window.ratio = Window.width / Window.height

function Window.draw() 
    local s = love.graphics.getHeight() / Window.height -- Scale factor
    love.graphics.scale(s, s) -- Scale local coords to fit window vertically
    love.graphics.translate((love.graphics.getWidth() - love.graphics.getHeight() * Window.ratio) / (2 * s), 0) -- Center local coords in window
end

return Window
