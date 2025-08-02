local generator = {
    item_table = {},
    map = {},
    shake_timers = {},
    shake_offsets = {},
}

local tile = require("data.tiles")
local INVENTORY = require("player.inventory")
local SPRITE = require("map.sprite_manager")

local scale = 0.01
local SHAKE_DURATION = 0.3
local SHAKE_MAGNITUDE = 3


local function key(x, y)
    return y .. "," .. x
end

function generator.generate(width, height, seed)
    seed = seed or 0

    local x_offset = (seed % 10000) * 100
    local y_offset = (math.floor(seed / 10000) % 10000) * 100

    local map = {}
    generator.item_table = {}
    generator.shake_timers = {}
    generator.shake_offsets = {}

    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            local n = love.math.noise((x + x_offset) * scale, (y + y_offset) * scale) + 0.1
            local selected_tile = tile.selection(n)
            map[y][x] = selected_tile
            
            for i=1,#SPRITE.existing_sprites do 
                if SPRITE.can_spawn(x,y,tostring(SPRITE.existing_sprites[i]),selected_tile) == true then 
                    SPRITE.load_sprite(x,y,SPRITE.existing_sprites[i])
                    break
                end
            end
        end
    end

    generator.map = map
    return map
end

return generator

