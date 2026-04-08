Object = require "lib.classic"
require "engine.input"

SceneGroup = Object:extend()

function SceneGroup.new(self, scenes, index)
    self.scenes = scenes -- Scenes is an array of Scene objects
    self.index = index or 1

    self.inputActive = true
end

function SceneGroup.draw(self)
    self.scenes[self.index]:draw()
end

function SceneGroup.PosInCb(x, y, cb)
    local bx1 = cb.x1
    local by1 = cb.y1
    local bx2 = cb.x2
    local by2 = cb.y2
    return (x >= bx1 and x <= bx2 and y >= by1 and y <= by2)
end

function SceneGroup.mousemoved(self)
    local x, y = Input.MousePosGlobal()
    local hovering = false

    for i, cb in ipairs(self.scenes[self.index].clickables) do
        if self.PosInCb(x, y, cb) then
            hovering = true
            break
        end
    end

    if hovering then
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    else
        love.mouse.setCursor()
    end
end

function SceneGroup.mousepressed(self)
    local x, y = Input.MousePosGlobal()
    if self.inputActive then
        for i, cb in ipairs(self.scenes[self.index].clickables) do
            if self.PosInCb(x, y, cb) then
                -- Clickable clicked
                self:ExecuteClickable(cb)
            end
        end
    end
end

function SceneGroup.ExecuteClickable(self, cb)
    local config = cb.config
    if config["trans"] ~= nil then
        self:Transition(config["trans"])
    end
end

function SceneGroup.Transition(self, i)
    self.index = i
end

return SceneGroup