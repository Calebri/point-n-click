--[[
    Class: SceneGroup
    Manages a group of scenes and their objects.

    table scenes: Table of individual scenes to be part of the SceneGroup
    number index: Index of the scene in scenes that is considered active
]]

Object = require "lib.classic"
require "engine.input"
require "engine.assets"

require "box"
require "item"

SceneGroup = Object:extend()

---@type table { [string]: function() }
local behaviors = {
    -- self table: SceneGroup
    -- any: Single value passed from config.

    ---@param v number Index of Scene to transition to.
    trans = function (self, v)
        self.index = v
    end,

    ---@param t table Table of values
    setflags = function (self, t)
        for k, v in pairs(t) do
            self.flags[k] = v
        end
    end,

    ---@param k string Key of flag to toggle
    toggleflag = function (self, k)
        self.flags[k] = not self.flags[k]
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

    openinvbox = function (self)
        self.inputActive = false

        if not self.box then
            self.box = Box.Open(self.items) -- Update when box can handle items
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

    ---@param i number
    enablecb = function (self, i)
        self:CurrentScene().clickables[i].active = true
    end,

    ---@param i number
    disablecb = function (self, i)
        self:CurrentScene().clickables[i].active = true
    end,

    ---@param item table Item to add to inventory.
    additem = function (self, item)
        table.insert(self.items, item)
    end,

    ---@param id string ID of item to remove from inventory. Will remove all instances if there are multiple.
    remitem = function (self, id)
        for i = #self.items, 1, -1 do
            local item = self.items[i]
            if item.id == id then
                table.remove(self.items, i)
            end
        end
    end,

    ---Executes behaviors conditionally. _ at the start of a flagName indicates to execute only if the flag is false.
    ---@param t table {flagName={behaviorToExecute}}
    switch = function (self, t)
        for key, value in pairs(t) do -- key is the name of the flag to check, value is the behavior to execute
            local inverse = false

            -- print("Testing key: " .. tostring(key))

            if key:sub(1, 1) == "_" then -- Check for inverse indicator
                inverse = true
                key = key:sub(2)
            end

            local flag = false

            if self.flags[key] then
                flag = self.flags[key]
            end

            if flag ~= inverse then -- XOR gate
                self:ExecuteClickable(value)
            end
        end
    end
}

---@param self table
---@param scenes table[]
---@param index? number
function SceneGroup.new(self, scenes, index)
    self.scenes = scenes -- Scenes is an array of Scene objects
    self.index = index or 1

    self.flags = {}

    self.inputActive = true
    
    self.box = nil

    self.invCb = Cb(10, 184, 44, 222)
    self.invImg = Assets.GetImg("img/bag/bag1.png")
    self.items = {
        Item("One", Assets.GetImg("img/item/testitem1.png")),
        Item("Two", Assets.GetImg("img/item/testitem2.png")),
        Item("Three", Assets.GetImg("img/item/testitem3.png")),
        Item("FOur", Assets.GetImg("img/item/testitem4.png"))
    }
end

function SceneGroup.update(self, dt)
    if self.box then
        self.box:update(dt)
    end
end

function SceneGroup.draw(self)
    self.scenes[self.index]:draw()

    for _, cb in pairs(self:CurrentScene().clickables) do
        if cb.flags then
            cb.active = self:FlagEval(cb.flags)
        end
    end
    
    love.graphics.draw(self.invImg)

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
        goto continue
    end

    if self.inputActive then -- Execute clicked clickable(s)
        if self.invCb and self.PosInCb(x, y, self.invCb) then
            -- Open Inventory menu
            behaviors["openinvbox"](self)
        end
    
        for _, cb in ipairs(self.scenes[self.index].clickables) do
            if cb.active and self.PosInCb(x, y, cb) then
                -- Clickable clicked
                self:ExecuteClickable(cb.config)
                goto continue
            end
        end
    end

    ::continue::
    self:UpdateMouse()
end

---Updates the cursor state depending on if it is hovering on a clickable.
---@param self table SceneGroup
function SceneGroup.UpdateMouse(self)
    local x, y = Input.MousePosGlobal()
    local hovering = false

    if self.inputActive then
        if self.invCb.active and self.PosInCb(x, y, self.invCb) then
            hovering = true
            goto done
        end

        for _, cb in ipairs(self.scenes[self.index].clickables) do
            if cb.active and self.PosInCb(x, y, cb) then
                hovering = true
                goto done
            end
        end
    end

    ::done::

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

---Execute Clickable on-click behavior
---@param self table SceneGroup
---@param config table
function SceneGroup.ExecuteClickable(self, config)
    -- local config = cb.config

    for key, behavior in pairs(behaviors) do
        if config[key] ~= nil then
            behavior(self, config[key])
        end
    end
end

---Returns true if all the flags evaulate to be true
---@param self table
---@param t string[] Array of flags
---@return boolean
function SceneGroup.FlagEval(self, t)
    for _, v in pairs(t) do
        local inverse = false

        if v:sub(1,1) == "_" then
            inverse = true
            v = v:sub(2)
        end

        if (not self.flags[v] or self.flags[v] == false) ~= inverse then -- ~= as XOR
            return false
        end
    end

    return true
end

return SceneGroup