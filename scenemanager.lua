Object = require "lib.classic"
require "engine.input"

SceneGroup = Object:extend()

function SceneGroup.new(self, scenes, index)
    self.scenes = scenes -- Scenes is an array of Scene objects
    self.index = index or 1

    self.inputActive = true
end

function SceneGroup.draw(self)
    self.scenes[index]:draw()
end

function SceneGroup.mousePressed(self, x, y, button, istouch, presses)
    x, y = Input.MousePosGlobal()
    if self.inputActive then
        for i, cb in ipairs(self.scenes[index].clickables) do
            if (x > cb.x and x < cb.x + cb.w
                and y > cb.y and y < cb.y + cb.h) then
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