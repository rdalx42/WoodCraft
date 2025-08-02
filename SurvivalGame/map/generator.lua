local generator = {
    item_table = {}, -- key = "y,x", value = {x, y, item_type, hp}
    map = {},
    shake_timers = {},
    shake_offsets = {},
}

local tile = require("data.tiles")
local INVENTORY = require("player.inventory")

local scale = 0.05
local SHAKE_DURATION = 0.3
local SHAKE_MAGNITUDE = 3


local item_ids = {}
for id in pairs(item_info) do
    table.insert(item_ids, id)
end

local function key(x, y)
    return y .. "," .. x
end

local function is_item(tile_id)
    for _, id in ipairs(item_ids) do
        if tile_id == id then return true end
    end
    return false
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

            if selected_tile == 5 and love.math.random() < 0.1 then
                selected_tile = 10 
                local k = key(x, y)
                generator.item_table[k] = {
                    x = x,
                    y = y,
                    item_type = selected_tile,
                    hp = item_info[selected_tile].hp
                }
            end

            map[y][x] = selected_tile
        end
    end

    generator.map = map
    return map
end

function generator.startShake(x, y)
    local k = key(x, y)
    generator.shake_timers[k] = SHAKE_DURATION
end

function generator.updateShake(dt)
    for k, timer in pairs(generator.shake_timers) do
        timer = timer - dt
        if timer <= 0 then
            generator.shake_timers[k] = nil
            generator.shake_offsets[k] = {x = 0, y = 0}
        else
            generator.shake_timers[k] = timer
            generator.shake_offsets[k] = {
                x = love.math.random(-SHAKE_MAGNITUDE, SHAKE_MAGNITUDE),
                y = love.math.random(-SHAKE_MAGNITUDE, SHAKE_MAGNITUDE)
            }
        end
    end
end

function generator.getShakeOffset(x, y)
    local k = key(x, y)
    return generator.shake_offsets[k] or {x = 0, y = 0}
end

function generator.destroyitem(map, x, y)
    local k = key(x, y)
    local item = generator.item_table[k]

    if item then
        item.hp = item.hp - 1
        generator.startShake(x, y)

        if item.hp <= 0 then
            inventory:add(item.item_type)
            generator.item_table[k] = nil
            generator.shake_timers[k] = nil
            generator.shake_offsets[k] = nil

            local return_tile = tile[item.item_type] and tile[item.item_type].returntype or 0
            map[y][x] = return_tile
        end
    end
end

return generator
