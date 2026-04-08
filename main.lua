require "engine.window"
require "engine.assets"

require "scenemanager"
require "scene"
Cb = require "clickable"

local debug = false

local scenes = {
    Scene(Assets.GetImg("img/test/testbg1.png"),
          {Cb(32,  16,  95,  63),
           Cb(128, 112, 239, 191)})
}

local sceneman = SceneGroup(scenes, 1)

function love.load()
    love.window.setMode(Window.width * 3, Window.height * 3, {resizable = true})
end

function love.update()
    
end

function love.mousemoved()
    sceneman:mousemoved()
end

function love.mousepressed()
    sceneman:mousepressed()
end

function love.draw()
    Window:draw()

    -- love.graphics.rectangle("fill", 0, 0, Window.width, Window.height)

    sceneman:draw()
end