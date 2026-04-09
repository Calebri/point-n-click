--[[
    Class: Clickable
    Area which is clickable within a Scene.

    number x1, y1: Coordinates of the top left of the Clickable area in global coordinates
    number x2, y2: Coordinates of the bottom right of the Clickable area in global coordinates
    table config: Table of key value pairs representing on-click behavior. Interpereted in scenemanager.lua
]]

Object = require "lib.classic"

Clickable = Object:extend()

function Clickable.new(self, x1, y1, x2, y2, config)
    self.x1 = x1 or 0
    self.y1 = y1 or 0
    self.x2 = x2 or 0
    self.y2 = y2 or 0

    self.config = config or {}
end

return Clickable