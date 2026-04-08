Assets = {}

function Assets.GetImg(path)
    local img = love.graphics.newImage(path)
    img:setFilter("nearest", "nearest")
end

return Assets