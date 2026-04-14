--[[
    Class: Box
]]

require "engine.window"
Timer = require "lib.timer"

Box = Object:extend()

local AnimState = {
    STOP = 0,
    EXPAND = 1,
    COLLAPSE = 2
}

function Box.new(self)
    -- Margin from the edge of screen
    self.marginx = 50
    self.marginy = 50

    -- Center of box
    self.x = Window.width / 2
    self.y = Window.height / 2

    -- Size
    self.w = Window.width - 2 * self.marginx
    self.h = Window.height - 2 * self.marginy

    -- Visual size
    self.vw = 0
    self.vh = 0

    -- Animation speed (pixel/s)
    -- self.speed = 8

    self.delay = 1

    -- Keeps track of animation state
    self.animstate = AnimState.STOP

    self.timer = Timer()
end

function Box.update(self, dt)
    self.timer:update(dt)

    -- Change logic based on animstate
    -- if self.animstate == AnimState.EXPAND then
    --     if self.vw >= self.w then
    --         self.vw = self.w
    --     else
    --         self.vw = self.vw + speed
    --     end

    --     if self.vh >= self.h then
    --         self.vh = self.h
    --     else
    --         self.vh = self.vh + speed
    --     end
    -- end
end

function Box.draw(self)
    -- Draw based on visual position
    love.graphics.rectangle("fill", self.x - self.vw / 2, self.y - self.vh / 2, self.vw, self.vh) -- temp rectangle
end

function Box.Open()
    local self = Box()

    self.animstate = AnimState.EXPAND

    local target = {
        vw = self.w,
        vh = self.h
    }

    self.timer:tween(self.delay, self, target, "linear", function ()
        self.animstate = AnimState.STOP
    end)

    return self

    -- Possibly we need a timer lib for this
    -- chrono.during or chrono.tween could work
end

function Box.Collapse(self, aftercallback)
    if self.animstate == AnimState.STOP then
        -- Collapse box
        self.animstate = AnimState.COLLAPSE

        local target = {
            vw = 0,
            vh = 0
        }

        self.timer:tween(self.delay, self, target, "linear", aftercallback)
    end
end

return Box