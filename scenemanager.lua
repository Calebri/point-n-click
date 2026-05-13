--[[
    Class: SceneGroup
    Manages a group of scenes and their objects.

    Scene[] scenes: Array of individual scenes to be part of the SceneGroup.
    number index: Index of the scene in scenes that is considered active.
    table flags: Table of set flag variables. Flags can be any type.
    boolean inputActive: Whether input is enabled in the SceneGroup.
    Box box?: Current Box in the SceneGroup.
    Clickable invCb: Clickable for the inventory button.
    Image invImg: Image for the inventory button.
    Item[] items: Items in the inventory.
    Timer timer: Timer object for the SceneGroup. Used primarily for transitions.
]]

Object = require "lib.classic"
Timer = require "lib.timer"

require "engine.input"
require "engine.assets"

require "box"
require "item"
require "shader"

SceneGroup = Object:extend()

---@param i number
---@return table
function SceneGroup.SetLoop(self, i)
    -- print(i)
    local totalLoops = 5
    local prefix = "loop"

    local out = {}

    for loopNum = 1, totalLoops, 1 do
        -- print(loopNum)
        out[prefix .. loopNum] = (loopNum == i)
        -- print(prefix .. loopNum .. " = " .. tostring(out[prefix .. loopNum]))
    end
    return out
end

function SceneGroup.GetLoop(self)
    local flags = self.flags

    local totalLoops = 5
    local prefix = "loop"

    local i = 0

    for loopNum = 1, totalLoops, 1 do
        if flags[prefix .. loopNum] then
            i = loopNum
            break
        end
    end

    return i
end

---Dictionary of behavior functions primarily for use by clickables.
---@type { [string]: function }
local behaviors = {
    -- self table: SceneGroup
    -- any: Single value passed from config.

    ---Open empty Box object.
    openbox = function (self)
        self.inputActive = false

        if not self.box then
            self.box = Box.Open()
        end
    end,

    ---Open Box object with given text as content.
    ---@param text string Text content.
    opentextbox = function (self, text)
        self.inputActive = false

        if not self.box then
            self.box = Box.Open(text)
        end
    end,

    ---Open Box object with player inventory as content.
    openinvbox = function (self)
        self.inputActive = false

        if not self.box then
            self.box = Box.Open(self.items) -- Update when box can handle items
        end
    end,

    ---Transition from the current scene to scene i.
    ---@param i number Index of Scene to transition to.
    trans = function (self, i)
        ---Transition update frequency
        local dt = 1/30

        ---Time it takes to transition in or out (not both)
        local transTime = 1/3

        ---Calculated amount of transition frames in or out (not both)
        local reps = transTime / dt

        ---Transition value to be passed to the shader
        local transition = 0

        local function UpdateShader()
            Shader.pixelBlur:send("transitionFactor", transition)
        end

        self.inputActive = false -- Take away input
        UpdateShader()
        self.timer:every(dt, function () -- Transition Into Blur
            transition = transition + 1 / reps
            UpdateShader()
        end, reps, function ()
            self.index = i -- Switch scene
            self.timer:every(dt, function () -- Transition Out Of Blur
                transition = transition - 1 / reps
                UpdateShader()
            end, reps, function ()
                transition = 0
                UpdateShader()
                self.inputActive = true -- Give back input
            end)
        end)
    end,

    ---Same as trans(), but without transition visuals.
    ---@param i number Index of Scene to transition to.
    transInstant = function (self, i)
        self.index = i
    end,

    ---Set SceneGroup flags to match given table.
    ---@param t table Table of values.
    setflags = function (self, t)
        for k, v in pairs(t) do
            self.flags[k] = v
        end
    end,

    ---Toggles boolean flag.
    ---@param k string Key of flag to toggle.
    toggleflag = function (self, k)
        self.flags[k] = not self.flags[k]
    end,

    ---Deactivates Addon in the current scene with the given index.
    ---@param i number Index of addon in current scene to hide.
    hide = function (self, i)
        self:CurrentScene().addons[i].active = false
    end,

    ---Activates Addon in the current scene with the given index.
    ---@param i number Index of addon in current scene to show.
    show = function (self, i)
        self:CurrentScene().addons[i].active = true
    end,

    ---Toggles active state of Addon in the current scene with the given index.
    ---@param i number Index of addon in current scene to toggle.
    toggle = function (self, i)
        self:CurrentScene().addons[i].active = not self:CurrentScene().addons[i].active
    end,

    ---Activates Clickable in current scene with the given index.
    ---@param i number Index of Clickable in current scene to activate.
    enablecb = function (self, i)
        self:CurrentScene().clickables[i].active = true
    end,

    ---Deactivates Clickable in the current scene with the given index.
    ---@param i number Index of Clickable in current scene to deactivate.
    disablecb = function (self, i)
        self:CurrentScene().clickables[i].active = true
    end,

    ---Add an item to the inventory.
    ---@param item table Item to add to inventory.
    additem = function (self, item)
        table.insert(self.items, item)
    end,

    ---Remove an item from the inventory. Will remove all instances if there are multiple.
    ---@param id string ID of item to remove from inventory. 
    remitem = function (self, id)
        for i = #self.items, 1, -1 do
            local item = self.items[i]
            if item.id == id then
                table.remove(self.items, i)
            end
        end
    end,

    ---Executes behaviors conditionally. _ at the start of a flagName indicates to execute only if the flag is false.
    ---@param t { [string]: { [string]: any } } {flagName={behaviorToExecute}}
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
    end,

    ---Execute behavior after all other behavior 
    ---@param conf { [string]: any}
    late = function (self, conf)
        self:ExecuteClickable(conf)
    end
}

behaviors["incrementloop"] = function(self, _)
    print("Incrementing loop")
    behaviors.setflags(self, self:SetLoop(self:GetLoop() + 1))
end

-- If there is time, rewrite this to init behaviors as a function for readability; This array should be automatic.
---@type string[]
local execOrder = {
    "openbox",
    "opentextbox",
    "openinvbox",
    "trans",
    "transInstant",
    "setflags",
    "toggleflag",
    "incrementloop",
    "hide",
    "show",
    "toggle",
    "enablecb",
    "disablecb",
    "additem",
    "remitem",
    "switch",
    "late"
}

---@param self table
---@param scenes table[]
---@param index? number
function SceneGroup.new(self, scenes, index, initialFlags)
    self.scenes = scenes -- Scenes is an array of Scene objects
    self.index = index or 1

    self.flags = initialFlags or {}

    self.inputActive = true
    
    self.box = nil

    self.invCb = Cb(10, 184, 44, 222)
    self.invImg = Assets.GetImg("img/bag/bag1.png")
    self.items = {
        -- Item("One", Assets.GetImg("img/item/testitem1.png")),
        -- Item("Two", Assets.GetImg("img/item/testitem2.png")),
        -- Item("Three", Assets.GetImg("img/item/testitem3.png")),
        -- Item("FOur", Assets.GetImg("img/item/testitem4.png"))
    }

    self.timer = Timer()
end

function SceneGroup.update(self, dt)
    self.timer:update(dt)

    if self.box then
        self.box:update(dt)
    end

    for _, cb in pairs(self:CurrentScene().clickables) do -- Evaluate CB flags
        if cb.flags then
            cb.active = self:FlagEval(cb.flags)
        end
    end
end

function SceneGroup.draw(self)
    for _, addon in ipairs(self:CurrentScene().addons) do -- Evaluate Addon flags
        if addon.flags then
            addon.active = self:FlagEval(addon.flags)
        end
    end

    self.scenes[self.index]:draw()
    
    love.graphics.draw(self.invImg)

    if self.box then
        self.box:draw(dt)
    end

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
    
    self.timer:script(function (wait)
        for _, key in ipairs(execOrder) do
            local behavior = behaviors[key]
            if config[key] ~= nil then
                behavior(self, config[key])
                while self.box do
                    wait(0.1)
                end
            end
        end
    end)
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