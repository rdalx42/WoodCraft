local TILE_SIZE = 32

local tiles = {
    [-1] = { name = "darkwater", image = nil, color = {0.09, 0.12, 0.25} },    
    [0]  = { name = "water", image = nil, color = {0.11, 0.14, 0.28} },           
    [1]  = { name = "grass", image = nil, color = {0.22, 0.34, 0.18} },
    [2]  = { name = "mountain", image = nil, color = {0.32, 0.35, 0.33} },     
    [3]  = { name = "darkgrass", image = nil, color = {0.21, 0.28, 0.15} },       
    [4]  = { name = "sand", image = nil, color = {0.82, 0.75, 0.58} },          
    [5]  = { name = "rock", image = nil, color = {0.44, 0.44, 0.42} },           
    [6]  = { name = "stone", image = nil, color = {0.59, 0.58, 0.56} },       
    [7]  = { name = "darkstone", image = nil, color = {0.29, 0.28, 0.27} }, 
    [8]  = { name = "dirt", image = nil, color = {0.36, 0.27, 0.14} },         
    [9]  = { name = "snow", image = nil, color = {0.9, 0.9, 0.9} },            
    [10] = { name = "deepwater", image = nil, color = {0.10, 0.13, 0.27} },
    [11] = { name = "wetgrass", image = nil, color = {0.24, 0.31, 0.17} },
    [12] = { name = "lightgrass", image = nil, color = {0.35, 0.39, 0.25} },
    [13] = { name = "drygrass", image = nil, color = {0.2, 0.26, 0.13} },
    [14] = { name = "lightrock", image = nil, color = {0.53, 0.52, 0.51} },
    [15] = { name = "beachsand", image = nil, color = {0.88, 0.82, 0.65} },  
    [16] = { name = "graystone", image = nil, color = {0.43, 0.43, 0.42} },
    [17] = { name = "darkdirt", image = nil, color = {0.3, 0.23, 0.1} },
    [18] = { name = "icyrock", image = nil, color = {0.62, 0.62, 0.6} },
    [19] = { name = "dustysand", image = nil, color = {0.75, 0.68, 0.55} },     
}

local tile_indices = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}

tiles.tile_indices  = tile_indices
tiles.generatorH = 300
tiles.generatorW = 300

function tiles.selection(n)
    if n < 0.11 then return -1
    elseif n < 0.15 then return 10
    elseif n < 0.28 then return 0
    elseif n < 0.32 then return 15
    elseif n < 0.37 then return 4
    elseif n < 0.42 then return 19
    elseif n < 0.53 then return 1
    elseif n < 0.56 then return 12
    elseif n < 0.58 then return 3
    elseif n < 0.61 then return 11
    elseif n < 0.65 then return 17
    elseif n < 0.7 then return 8
    elseif n < 0.74 then return 7
    elseif n < 0.78 then return 6
    elseif n < 0.81 then return 18
    elseif n < 0.84 then return 14
    elseif n < 0.9 then return 5
    elseif n < 0.93 then return 16
    elseif n < 0.97 then return 2
    else return 9
    end
end

function loadTileImages()
    for id, tile in pairs(tiles) do
        if type(tile) == "table" and tile.image_path then
            tile.image = love.graphics.newImage(tile.image_path)
        end
    end
end

function love.load()
    loadTileImages()
end

return tiles
