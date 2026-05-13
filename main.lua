Timer = require "lib.timer"

require "utils.window"
require "utils.assets"

require "engine.scenemanager"
require "engine.scene"
Cb = require "engine.clickable"
require "engine.addon"
require "engine.box"
require "engine.shader"

local debug = false

local DEFAULT_SCALE = 1

-- local testSwitch = {
--     testFlag = {opentextbox="testFlag = true"},
--     _testFlag = {setflags={testFlag=true}},
-- }

local timer = Timer()

local scenes

if debug then
    scenes = {
        Scene(Assets.GetImg("img/test/testbg1.png"),
                {Cb( 32,  16,  96,  64, {trans=2}),
                Cb(128, 112, 240, 192, {opentextbox="Test text content. 123456789"}, true, {"testFlag"}),
                Cb(166,  30, 226,  74, {toggleflag="testFlag"})},
                {Addon(Assets.GetImg("img/test/testbg1-addon1.png"))}),
        Scene(Assets.GetImg("img/test/testbg2.png"),
                {Cb(12,  82,  66, 200, {trans=1})})
    }
else -- \/ MAIN SCENES LIST \/
    scenes = {}
    
    scenes[1] = Scene(Assets.GetImg("img/scenes/lobby.png"), -- Lobby
                        {Cb(270, 158, 381, 264, {trans=2}), -- Check-In Box
                        --  Cb( 40,   0, 611,  80, {trans=3}), -- Placeholder Top Doors CB
                         Cb( 55,  23, 114, 122, {opentextbox="It's locked."}), -- Left Door
                         Cb(538,  23, 597, 122, {trans=3}),
                         Cb(145, 125, 411, 153, {opentextbox="It says \"CHECK-IN\"."}), -- Check-In Text
                         Cb(235, 264, 407, 415, {opentextbox="There are some stairs leading up to a small booth."}), -- Front stairs
                         Cb(  0, 460, 650, 490, {opentextbox="No going back now."})
                        },
                        {Addon(Assets.GetImg("img/scenes/lobby_man.png"), {flags={"_loop5"}})}) -- Man
    
    scenes[2] = Scene(Assets.GetImg("img/scenes/checkin.png"), -- Check-In
                        {Cb(250, 370, 400, 480, {trans=1}), -- Arrow Button
                         Cb(160,  44, 489, 250, {opentextbox="He's not there anymore..."}, {flags={"loop5"}}), -- Area Behind
                         Cb(368, 122, 488, 298, -- Man
                            {opentextbox="\"Good evening, I'm sure you've had a long day of travel. Your room is ready for you. Please, go get some rest, your belongings will be waiting for you upstairs.\"",
                             switch={
                                     loop1={opentextbox="Is this real?", late={opentextbox="\"...\""}},
                                     loop2={opentextbox="Do you have any idea what's going on?", late={opentextbox="\"...\"", late={opentextbox="This doesn't make any sense."}}},
                                     loop3={opentextbox="You've said that three times now...", late={opentextbox="\"...\""}},
                                     loop4={opentextbox="You've GOT to be kidding me. You're really not going to say anything else?", late={opentextbox="\"...\""}}
                                    }},
                            {flags={"_loop5"}}),
                         Cb( 75, 239, 160, 331, {opentextbox="It's a small lamp."}), -- Lamp 1
                         Cb(489, 239, 573, 331, {opentextbox="It's a small lamp."}), -- Lamp 2
                         Cb(343, 309, 392, 330, {setflags={keyCollected=true}, additem=Item("key", Assets.GetImg("img/item/key.png")), opentextbox="You picked up the key."}, {flags={"_keyCollected"}}), -- Key
                        },
                        {Addon(Assets.GetImg("img/scenes/checkin_key.png"), {flags={"_keyCollected"}}), -- Key
                         Addon(Assets.GetImg("img/scenes/checkin_man.png"), {flags={"_loop5"}})
                        })
    
    scenes[3] = Scene(Assets.GetImg("img/scenes/hallway.png"), -- Hallway
                        {Cb( 79,  73, 160, 490, {switch={_loop4={opentextbox="It's locked"}, loop4={trans=5}}}), -- Door L1
                         Cb(185, 128, 225, 401, {opentextbox="It's locked"}), -- Door L2
                         Cb(240, 158, 256, 336, {opentextbox="It's locked"}), -- Door L3
                         Cb(291, 168, 353, 300, {switch={_loop4={switch={_keyCollected={opentextbox="It's locked"}, keyCollected={opentextbox="You unlock the door with the key.", trans=4}}}, loop4={opentextbox="Was that other door open before?"}}}), -- Door Center
                         Cb(387, 158, 403, 336, {opentextbox="It's locked"}), -- Door R1
                         Cb(418, 128, 459, 401, {opentextbox="It's locked"}), -- Door R2
                         Cb(485,  73, 565, 490, {opentextbox="It's locked"}), -- Door R3
                         Cb(280, 430, 360, 480, {trans=1}) -- Turnaround
                        },
                        {Addon(Assets.GetImg("img/scenes/hallway_1.png"), {flags={"loop3"}}), -- Slightly darker
                         Addon(Assets.GetImg("img/scenes/hallway_2.png"), {flags={"loop4"}}), -- Door Ajar
                         Addon(Assets.GetImg("img/scenes/hallway_3.png"), {flags={"loop5"}}), -- Scary ver
                         Addon(Assets.GetImg("img/scenes/turnaround.png"))
                        })
    
    scenes[4] = Scene(Assets.GetImg("img/scenes/room.png"), -- Hotel Room
                        {Cb(  6, 410, 117, 473, {opentextbox="NOTE TEXT HERE"}), -- Note
                         Cb(122, 330, 443, 401, {opentextbox="You feel tired and decide to go to sleep.", setflags={keyCollected=false}, remitem="key", incrementloop=true, trans=1}), -- Bed
                         Cb(101, 137, 231, 234, {opentextbox="A jovial painting. For some reason it makes you feel nauseous."}), -- Painting
                         Cb(250,  80, 427, 333, {opentextbox="A large wardrobe."}), -- Wardrobe
                         Cb(462,  77, 612, 277, {opentextbox="It looks like a window, but theres nothing on the other side."}), -- Window
                         Cb(401, 408, 542, 489, {opentextbox="A small suitcase. It's locked."}), -- Suitcase
                        })

    scenes[5] = Scene(Assets.GetImg("img/end_of_demo.png"))

end

local flags = {
    keyCollected = false,
    loop1 = true,
    loop2 = false,
    loop3 = false,
    loop4 = false,
    loop5 = false
}

local sceneman = SceneGroup(scenes, 1, flags)

local titleImage = Assets.GetImg("img/title_placeholder_2.png")
local introText = "It looks like the lobby of a hotel. You can't quite remember how you got here."
local gameStarted = false
local c = 1

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setMode(Window.width * DEFAULT_SCALE, Window.height * DEFAULT_SCALE, {resizable = true})

    love.graphics.setShader(Shader.pixelBlur)
end

function love.update(dt)
    timer:update(dt)

    if gameStarted then
        sceneman:update(dt)
    end

    -- print(sceneman:GetLoop())
end

function love.draw()
    Window:draw()

    if gameStarted then
        sceneman:draw()
    else
        love.graphics.draw(titleImage)
    end
end

function love.mousepressed()
    if gameStarted then
        sceneman:mousepressed()
    elseif c == 1 then -- Close the title screen
        local function UpdateShader()
            Shader.pixelBlur:send("transitionFactor", 1 - c)
            love.graphics.setColor(c, c, c)
        end

        local dt = 1/30
        local reps = 30

        timer:every(dt, function ()
            c = c - dt
            UpdateShader()
        end, reps, function ()
            sceneman.InputActive = false
            gameStarted = true
            timer:every(dt, function ()
                c = c + dt
                UpdateShader()
            end, reps, function ()
                sceneman:ExecuteClickable({opentextbox=introText})
            end)
        end)
    end
end