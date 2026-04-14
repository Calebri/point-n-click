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

    self.delay = 0.5

    -- Keeps track of animation state
    self.animstate = AnimState.STOP

    self.timer = Timer()
end

function Box.update(self, dt)
    self.timer:update(dt)
end

function Box.draw(self)
    -- Draw based on visual position
    love.graphics.setColor(love.math.colorFromBytes(81, 172, 252))
    love.graphics.rectangle("fill", self.x - self.vw / 2, self.y - self.vh / 2, self.vw, self.vh) -- temp rectangle
    love.graphics.setColor(1, 1, 1)
end

---@param h? number
---@param w? number
---@return table Box
function Box.Open(h, w)
    local self = Box()

    self.h = h or self.h
    self.w = w or self.w

    self.animstate = AnimState.EXPAND

    local target = {
        vw = self.w,
        vh = self.h
    }

    self.timer:tween(self.delay, self, target, "linear", function ()
        self.animstate = AnimState.STOP
    end)

    return self
end

---@param self table
---@param aftercallback function Function to run after animation finishes.
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