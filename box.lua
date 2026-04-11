--[[
    Class: Box
]]

require "engine.window"

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
    self.w = Window.width + 2 * self.marginx
    self.h = Window.height + 2 * self.marginy

    -- Visual size
    self.vw = 0
    self.vh = 0

    -- Animation speed (pixel/s)
    self.speed = 8

    -- Keeps track of animation state
    self.animstate = AnimState.STOP
end

function Box.update(self, dt)
    -- Change logic based on animstate
    if self.animstate == AnimState.EXPAND then
        if self.vw >= self.w then
            self.vw = self.w
        else
            self.vw = self.vw + speed
        end

        if self.vh >= self.h then
            self.vh = self.h
        else
            self.vh = self.vh + speed
        end
    end
end

function Box.draw(self)
    -- Draw based on visual position
    love.graphics.rectangle("fill", self.x - self.vw / 2, self.y - self.vh / 2, self.vw, self.vh) -- temp rectangle
end

function Box.OpenAsync()
    local box = Box()

    box.animstate = AnimState.EXPAND

    -- Possibly we need a timer lib for this
    -- chrono.during or chrono.tween could work
end

function Box.CollapseAsync(self)

end

return Box