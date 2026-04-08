Object = require "lib.classic"

Clickable = Object:extend()

function Clickable.new(self, x1, y1, x2, y2, config)
    self.x1 = x1
    self.y1 = y1
    self.x2 = x2
    self.y2 = y2

    self.config = config or {}
end

return Clickable