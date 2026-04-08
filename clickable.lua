Object = require "lib.classic"

Clickable = Object:extend()

function Clickable.new(self, x, y, w, h, config)
    self.x = x
    self.y = y
    self.w = w
    self.h = h

    self.config = config
end

return Clickable