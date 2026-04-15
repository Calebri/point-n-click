--[[
    Class: SceneGroup
    Manages a group of scenes and their objects.

    table scenes: Table of individual scenes to be part of the SceneGroup
    number index: Index of the scene in scenes that is considered active
]]

Object = require "lib.classic"
require "engine.input"

require "box"

SceneGroup = Object:extend()

function SceneGroup.new(self, scenes, index)
    self.scenes = scenes -- Scenes is an array of Scene objects
    self.index = index or 1

    self.globalFlags = {}

    self.inputActive = true
    
    self.box = nil
end

function SceneGroup.update(self, dt)
    if self.box then
        self.box:update(dt)
    end
end

function SceneGroup.draw(self)
    self.scenes[self.index]:draw()
    
    if self.box then
        self.box:draw(dt)
    end
end

function SceneGroup.mousemoved(self)
    self:UpdateMouse()
end

function SceneGroup.mousepressed(self)
    local x, y = Input.MousePosGlobal()

    if self.box then -- Closes current Box
        self.box:Collapse(function ()
            self.box = nil
            self.inputActive = true
        end)
    end

    if self.inputActive then -- Execute clicked clickable(s)
        for _, cb in ipairs(self.scenes[self.index].clickables) do
            if self.PosInCb(x, y, cb) then
                -- Clickable clicked
                self:ExecuteClickable(cb)
            end
        end
    end

    self:UpdateMouse()
end

---Updates the cursor state depending on if it is hovering on a clickable.
---@param self table SceneGroup
function SceneGroup.UpdateMouse(self)
    local x, y = Input.MousePosGlobal()
    local hovering = false

    if self.inputActive then
        for _, cb in ipairs(self.scenes[self.index].clickables) do
            if self.PosInCb(x, y, cb) then
                hovering = true
                break
            end
        end
    end


    if hovering then
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    else
        love.mouse.setCursor()
    end
end

---Returns whether a position lies inside a Clickable.
---@param x number X position (global).
---@param y number Y position (global).
---@param cb table Clickable
---@return boolean
function SceneGroup.PosInCb(x, y, cb)
    local bx1 = cb.x1
    local by1 = cb.y1
    local bx2 = cb.x2
    local by2 = cb.y2
    return (x >= bx1 and x <= bx2 and y >= by1 and y <= by2)
end

---Return the current scene
---@param self table SceneGroup
---@return table Scene
function SceneGroup.CurrentScene(self)
    return self.scenes[self.index]
end

---@type table { [string]: function() }
local behaviors = {
    -- self table: SceneGroup
    -- any: Single value passed from config.

    ---@param v number Index of Scene to transition to.
    trans = function (self, v)
        self.index = v
    end,

    openbox = function (self)
        self.inputActive = false

        if not self.box then
            self.box = Box.Open()
        end
    end,

    ---@param text string Text content
    opentextbox = function (self, text)
        self.inputActive = false

        if not self.box then
            self.box = Box.Open(text)
        end
    end,

    ---@param v number Index of addon in current scene to hide.
    hide = function (self, v)
        self:CurrentScene().addons[v].active = false
    end,

    ---@param v number Index of addon in current scene to show.
    show = function (self, v)
        self:CurrentScene().addons[v].active = true
    end,

    ---@param v number Index of addon in current scene to toggle.
    toggle = function (self, v)
        self:CurrentScene().addons[v].active = not self:CurrentScene().addons[v].active
    end,
    
    ---@param v number Index of clickable in current Scene to destroy.
    destroy = function (self, v)
        table.remove(self:CurrentScene().clickables, v) -- Change to disable clickable insead?
    end
}

---Execute Clickable on-click behavior
---@param self table SceneGroup
---@param cb table Clickable
function SceneGroup.ExecuteClickable(self, cb)
    local config = cb.config

    for key, behavior in pairs(behaviors) do
        if config[key] ~= nil then
            behavior(self, config[key])
        end
    end
end

return SceneGroup