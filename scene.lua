--[[
    Class: Scene
    A single scene, for use within a SceneGroup

    Image background: Image to draw when the scene is active
    table clickables: Table of Clickables to associate with the scene
    table addons: Table of Addons to associate with the scene
]]

Object = require "lib.classic"

Scene = Object:extend()

function Scene.new(self, background, clickables, addons)
    self.background = background or love.graphics.newImage()
    self.clickables = clickables or {}
    self.addons = addons or {}
end

function Scene.draw(self)
    love.graphics.draw(self.background)
    for _, addon in ipairs(self.addons) do
        addon:draw()
    end
end

return Scene