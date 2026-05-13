--[[
    Class: Box
]]

require "utils.window"
Timer = require "lib.timer"

require("utils.stringops")

require("engine.item")

Box = Object:extend()

local font = love.graphics.newFont("font/VCR_OSD_MONO.ttf", 36)
-- local font = love.graphics.newFont(10, "mono")
font:setFilter("nearest", "nearest")
local textScale = 1 --3

local AnimState = {
    STOP = 0,
    EXPAND = 1,
    COLLAPSE = 2
}

---@param content? table
function Box.new(self, content)
    -- Margin from the edge of screen
    self.marginx = Window.width / 10 -- 25
    self.marginy = Window.height / 8 --30

    -- Center of box
    self.x = Window.width / 2
    self.y = Window.height / 2

    -- Size
    self.w = Window.width - 2 * self.marginx
    self.h = Window.height - 2 * self.marginy

    -- Visual size
    self.vw = 0
    self.vh = 0

    if content then
        -- Text Attributes
        if content["text"] then
            self.text = content["text"]
            self.tscale = textScale
            self.tmargin = 5
        end

        -- Items
        if content["items"] then
            self.items = content["items"]
            self.columns = 3
        end
    end

    -- Time delay to open/close a box
    self.delay = 0.3

    -- Keeps track of animation state
    self.animstate = AnimState.STOP

    self.timer = Timer()

    -- Process Text
    if self.text then
        local words = StringOps.split(self.text)

        local lines = {}
        local currentLine = 1

        local tspace = (self.w - 2 * self.tmargin) -- Width that is occupied by text

        for _, word in ipairs(words) do -- Seperate words into lines
            if font:getWidth(word) * self.tscale > tspace then
                print("Word is too large: " .. word)
                goto continue -- Skip words that are too large
            end

            local temp
            if lines[currentLine] then
                temp = lines[currentLine] .. " " .. word
            else
                temp = word
            end

            if font:getWidth(temp) * self.tscale <= tspace then
                lines[currentLine] = temp
            else -- width > tspace
                currentLine = currentLine + 1
                lines[currentLine] = word
            end

            ::continue::
        end

        self.text = table.concat(lines, "\n")

        self.h = (#lines * font:getHeight() * self.tscale) + (2 * self.tmargin)
    end

    -- Draw Content Canvas
    local defaultCanvas = love.graphics.getCanvas()

    self.canvas = love.graphics.newCanvas(self.w, self.h)
    love.graphics.setCanvas(self.canvas)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.origin()

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h) -- temp rectangle
    love.graphics.setColor(1, 1, 1)

    -- Render Text
    if self.text then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(self.text, font, self.tmargin, self.tmargin, 0, self.tscale)
    end

    -- Render Items
    if self.items then
        for i, item in ipairs(self.items) do
            love.graphics.draw(item.img, -- Worst draw call in the whole game
                                ((i - 1) % self.columns) * (self.w / self.columns) + (self.w  / self.columns / 2) - (item.img:getWidth() / 2), -- X
                                (math.floor((i - 1) / self.columns) + 0.5) * self.h / 5) -- Y
        end
    end

    love.graphics.setCanvas(defaultCanvas)

    -- Start animation
    self.animstate = AnimState.EXPAND

    local target = {
        vw = self.w,
        vh = self.h
    }

    self.timer:tween(self.delay, self, target, "linear", function ()
        self.animstate = AnimState.STOP
    end)
end

function Box.update(self, dt)
    self.timer:update(dt)
end

function Box.draw(self)
    -- Draw based on visual position
    love.graphics.draw(self.canvas, self.x - self.vw / 2, self.y - self.vh / 2, 0, self.vw / self.w)
end

---Instantiate new Box.
---@param content? string|table Box content. String content will open the Box as a text box. Table content will open the Box as an inventory preview.
---@return table Box New Box instance.
function Box.Open(content)
    local self

    if type(content) == "string" then -- Text Box
        self = Box({text=content})
    elseif type(content) == "table" then -- Inventory Preview
        self = Box({items=content})
    else -- Empty Box
        self = Box()
    end

    return self
end

---@param self table
---@param closecallback function Function to run after animation finishes.
function Box.Collapse(self, closecallback)
    if self.animstate == AnimState.STOP then
        -- Collapse box
        self.animstate = AnimState.COLLAPSE

        local target = {
            vw = 0,
            vh = 0
        }

        self.timer:tween(self.delay, self, target, "linear", closecallback)
    else
        print("Box failed to collapse because it is still animating.")
    end
end

return Box