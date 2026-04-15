--[[
    Class: Box
]]

require "engine.window"
Timer = require "lib.timer"

Box = Object:extend()

-- local font = love.graphics.newFont("font/VCR_OSD_MONO.ttf", 12)
local font = love.graphics.newFont(12, "mono")
font:setFilter("nearest", "nearest")

local AnimState = {
    STOP = 0,
    EXPAND = 1,
    COLLAPSE = 2
}

---@param text? string
function Box.new(self, text)
    -- Margin from the edge of screen
    self.marginx = 25
    self.marginy = 30

    -- Center of box
    self.x = Window.width / 2
    self.y = Window.height / 2

    -- Size
    self.w = Window.width - 2 * self.marginx
    self.h = Window.height - 2 * self.marginy

    -- Visual size
    self.vw = 0
    self.vh = 0

    self.text = text
    self.tscale = 1
    self.tmargin = 5

    -- Animation speed (pixel/s)
    -- self.speed = 8

    self.delay = 0.3

    -- Keeps track of animation state
    self.animstate = AnimState.STOP

    self.timer = Timer()

    -- Process Text
    if self.text then
        self.h = font:getHeight() + 2 * self.tmargin
    end

    -- Draw Content Canvas
    self.canvas = love.graphics.newCanvas(self.w, self.h)
    love.graphics.setCanvas(self.canvas)
    love.graphics.origin()
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h) -- temp rectangle
    love.graphics.setColor(1, 1, 1)

    if self.text then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(self.text, font, self.tmargin, self.tmargin, 0, self.tscale)
    end

    love.graphics.setCanvas()
end

function Box.update(self, dt)
    self.timer:update(dt)
end

function Box.draw(self)
    -- Draw based on visual position
    love.graphics.draw(self.canvas, self.x - self.vw / 2, self.y - self.vh / 2, 0, self.vw / self.w)
end

---@param text? string
---@return table Box
function Box.Open(text)
    local self = Box(text)

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