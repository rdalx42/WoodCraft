
local tiles = {
    [-1] = { name = "darkwater", image = nil, color = {0.05, 0.07, 0.2} },   
    [0] = { name = "water", image = nil, color = {0.1, 0.3, 0.5} },          
    [1] = { name = "grass", image = nil, color = {0.3, 0.5, 0.2} },         
    [2] = { name = "mountain", image = nil, color = {0.5, 0.48, 0.44} },     
    [3] = { name = "darkgrass", image = nil, color = {0.2, 0.3, 0.1} },      
    [4] = { name = "sand", image = nil, color = {0.76, 0.7, 0.55} },         
    [5] = { name = "rock", image = nil, color = {0.4, 0.4, 0.38} },         
    [6] = { name = "stone", image = nil, color = {0.65, 0.64, 0.6} },         
    [7] = { name = "darkstone", image = nil, color = {0.25, 0.25, 0.25} }, 
    [8] = { name = "dirt", image = nil, color = {0.35, 0.25, 0.1} },         
    [9] = { name = "snow", image = nil, color = {0.9, 0.9, 0.9} },           
    [10] = { name = "smallrock", image = nil, returntype = 6, color = {0.55, 0.55, 0.5}, hp = 10} ,
    [11] = {name = "treebottom", image = nil , returntype = 1, color = {0.55,0.55,0.5},hp=10},
    [12] = {name = "treetop", image = nil , color = {0.55,0.55,0.5},returntype = 1},
}


local tiles_with_images = {10,11,12} 

function tiles.loadImages()
    for i, id in ipairs(tiles_with_images) do
        local tile = tiles[id]
        if tile then
            tile.image = love.graphics.newImage("assets/tiles/" .. tile.name .. ".png")
        end
    end
end

function tiles.selection(n)
    if n < 0.15 then return -1
    elseif n < 0.25 then return 0
    elseif n < 0.35 then return 4
    elseif n < 0.55 then return 1
    elseif n < 0.65 then return 3
    elseif n < 0.75 then return 8
    elseif n < 0.85 then return 6
    elseif n < 0.92 then return 5
    elseif n < 0.98 then return 2
    else return 9 end
end

return tiles

