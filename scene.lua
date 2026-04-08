Object = require "lib.classic"

Scene = Object:extend()

function Scene.new(self, background, clickables)
    assert(type(background) == love.graphics.Image)
    self.background = background or love.graphics.newImage()
    self.clickables = clickables    
end

function Scene.draw(self)
    love.graphics.draw(self.background, 0, 0, Window.width, Window.height)
end

return Scene