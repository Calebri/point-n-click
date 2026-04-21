require "engine.window"
require "engine.assets"

require "scenemanager"
require "scene"
Cb = require "clickable"
require "addon"
require "box"

-- local debug = false

local DEFAULT_SCALE = 3

local testSwitch = {
    testFlag = {opentextbox="testFlag = true"},
    _testFlag = {setflags={testFlag=true}},
}

local scenes = {
    Scene(Assets.GetImg("img/test/testbg1.png"),
            {Cb( 32,  16,  96,  64, {trans=2}),
             Cb(128, 112, 240, 192, {opentextbox="Test text content. 123456789"}, false),
             Cb(166,  30, 226,  74, {enablecb=2})},
            {Addon(Assets.GetImg("img/test/testbg1-addon1.png"), true)}),
    Scene(Assets.GetImg("img/test/testbg2.png"),
            {Cb(12,  82,  66, 200, {trans=1})})
}
local sceneman = SceneGroup(scenes, 1)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setMode(Window.width * DEFAULT_SCALE, Window.height * DEFAULT_SCALE, {resizable = true})
end

function love.update(dt)
    sceneman:update(dt)
end

function love.draw()
    Window:draw()

    sceneman:draw()
end

function love.mousemoved()
    sceneman:mousemoved()
end

function love.mousepressed()
    sceneman:mousepressed()
end