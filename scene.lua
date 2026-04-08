Object = require "lib.classic"

Scene = Object:extend()

function Scene.new(self, background, clickables)
    self.background = background or love.graphics.newImage()
    self.clickables = clickables    
end

function Scene.draw(self)
    love.graphics.draw(self.background)
end

return Scene