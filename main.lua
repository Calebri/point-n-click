require "engine.window"
require "engine.assets"

require "scenemanager"
require "scene"
Cb = require "clickable"
require "addon"
require "box"

local debug = false

local scenes = {
    Scene(Assets.GetImg("img/test/testbg1.png"),
            {Cb(32,  16,  96,  64, {trans=2}),
            Cb(128, 112, 240, 192, {opentextbox="Test text content. 123456789"}),
            Cb(166,  30, 226,  74, {opentextbox="This is a test long text box. There is a lot of text in this box in order to test the ability of the new code to automatically split the text into individual lines and display them on screen."})},
            {Addon(Assets.GetImg("img/test/testbg1-addon1.png"), true)}),
    Scene(Assets.GetImg("img/test/testbg2.png"),
            {Cb(12,  82,  66, 200, {trans=1})})
}

local sceneman = SceneGroup(scenes, 1)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setMode(Window.width * 3, Window.height * 3, {resizable = true})
end

function love.update(dt)
    sceneman:update(dt)
end

function love.draw()
    Window:draw()

    -- love.graphics.rectangle("fill", 0, 0, Window.width, Window.height)

    sceneman:draw()
end

function love.mousemoved()
    sceneman:mousemoved()
end

function love.mousepressed()
    sceneman:mousepressed()
end