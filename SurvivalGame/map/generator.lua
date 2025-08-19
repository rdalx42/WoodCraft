local generator = {
    item_table = {},
    map = {},
    shake_timers = {},
    shake_offsets = {},
}

local tile = require("data.tiles")
local SPRITE = require("map.sprite_manager")

local scale = 0.005

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

    local noise = love.math.noise
    local selection = tile.selection
    local sprites = SPRITE.existing_sprites
    local load_sprite = SPRITE.load_sprite

    for y = 1, height do
        local row = {}
        map[y] = row
        for x = 1, width do
            
            local n = noise((x + x_offset) * scale, (y + y_offset) * scale) + 0.1
            local selected_tile = selection(n)
            row[x] = selected_tile
            local possible_sprites = sprites
            
            local selected_sprite = math.random(1,#possible_sprites)
            local spr = possible_sprites[selected_sprite]
            
            if(SPRITE.can_spawn(x,y,spr,selected_tile))then load_sprite(x,y,spr,selected_sprite)end

        end
    end

    generator.map = map
    return map
end

function generator.getShakeOffset(x, y)
    local k = key(x, y)
    return generator.shake_offsets[k] or {x = 0, y = 0}
end

return generator
