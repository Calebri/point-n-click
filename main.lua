require "engine.window"

function love.load()
    love.window.setMode(Window.width * 3, Window.height * 3, {resizable = true})
end

function love.update()
    
end

function love.draw()
    Window:draw()

    love.graphics.rectangle("fill", 0, 0, Window.width, Window.height)
end