require "engine.window"
require "engine.assets"

require "scenemanager"
require "scene"
Cb = require "clickable"
require "addon"
require "box"

local debug = false

local DEFAULT_SCALE = 1

local testSwitch = {
    testFlag = {opentextbox="testFlag = true"},
    _testFlag = {setflags={testFlag=true}},
}

local scenes

if debug then
    scenes = {
        Scene(Assets.GetImg("img/test/testbg1.png"),
                {Cb( 32,  16,  96,  64, {trans=2}),
                Cb(128, 112, 240, 192, {opentextbox="Test text content. 123456789"}, true, {"testFlag"}),
                Cb(166,  30, 226,  74, {toggleflag="testFlag"})},
                {Addon(Assets.GetImg("img/test/testbg1-addon1.png"), true)}),
        Scene(Assets.GetImg("img/test/testbg2.png"),
                {Cb(12,  82,  66, 200, {trans=1})})
    }
else -- \/ MAIN SCENES LIST \/
    scenes = {}

    scenes[1] = Scene(Assets.GetImg("img/scenes/lobby.png"), -- Lobby
                        {Cb(270, 158, 381, 264, {trans=2}), -- Check-In Box
                        })
    
    scenes[2] = Scene(Assets.GetImg("img/scenes/checkin.png"), -- Check-In
                        {Cb(250, 370, 400, 480, {trans=1}), -- Arrow Button
                         Cb(160,  44, 489, 250), -- Area Behind
                         Cb( 75, 239, 160, 331), -- Lamp 1
                         Cb(489, 239, 573, 331), -- Lamp 2
                         Cb(343, 309, 392, 330), -- Key
                        },
                        {Addon(Assets.GetImg("img/scenes/checkin_key.png", true))}) -- Key
    
    scenes[3] = Scene(Assets.GetImg("img/scenes/hallway.png"), -- Hallway
                        {Cb( 79,  73, 160, 490), -- Door L1
                         Cb(185, 128, 225, 401), -- Door L2
                         Cb(240, 158, 256, 336), -- Door L3
                         Cb(291, 168, 353, 300), -- Door Center
                         Cb(387, 158, 403, 336), -- Door R1
                         Cb(418, 128, 459, 401), -- Door R2
                         Cb(485,  73, 565, 490), -- Door R3
                        })
    
    scenes[4] = Scene(Assets.GetImg("img/scenes/room.png"), -- Hotel Room
                        {Cb(  6, 410, 117, 473), -- Note
                         Cb(122, 330, 443, 401), -- Bed
                         Cb(101, 137, 231, 234), -- Painting
                         Cb(513,  80, 427, 333), -- Wardrobe
                         Cb(462,  77, 612, 277), -- Window
                         Cb(401, 408, 542, 489), -- Suitcase
                        })

end

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