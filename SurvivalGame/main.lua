
local MOVEMENT = require("player.movement")
local INVENTORY = require("player.inventory")
local MAP_INFO = require("map.generator")
local TILES = require("data.tiles")
local camera = require("libraries.camera")

local TILE_SIZE = 30
inventory = INVENTORY.new(30, 30)
local map = MAP_INFO.generate(100, 100, love.math.random(10,1000))
cam = nil

function love.load()
    TILES.loadImages()
    MOVEMENT.set_player({x = 500, y = 500},100)
    cam = camera()
end

function love.update(dt)
    cam:lookAt(MOVEMENT.player_object.x, MOVEMENT.player_object.y)
    MAP_INFO.updateShake(dt)
    MOVEMENT.get(dt)
end

function love.draw()
    
    cam:attach()
        for y = 1, #map do
            for x = 1, #map[y] do
                local tile_id = map[y][x]
                local tile_info = TILES[tile_id]

                local offset_x, offset_y = 0, 0
                if tile_id == 10 then
                    local offset = MAP_INFO.getShakeOffset(x, y)
                    offset_x = offset.x or 0
                    offset_y = offset.y or 0
                elseif tile_id == 11 then  
                    local offset = MAP_INFO.getShakeOffset(x, y)
                    offset_x = offset.x or 0
                    offset_y = offset.y or 0
                    
                end

                if tile_info then
                    if tile_info.image then
                        local scale = TILE_SIZE / tile_info.image:getWidth()
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.draw(tile_info.image, (x - 1) * TILE_SIZE + offset_x, (y - 1) * TILE_SIZE + offset_y, 0, scale, scale)
                    elseif tile_info.color then
                        love.graphics.setColor(tile_info.color)
                        love.graphics.rectangle("fill", (x - 1) * TILE_SIZE + offset_x, (y - 1) * TILE_SIZE + offset_y, TILE_SIZE, TILE_SIZE)
                    else
                        love.graphics.setColor(1, 0, 1)
                        love.graphics.rectangle("fill", (x - 1) * TILE_SIZE + offset_x, (y - 1) * TILE_SIZE + offset_y, TILE_SIZE, TILE_SIZE)
                    end
                else
                    love.graphics.setColor(1, 0, 1)
                    love.graphics.rectangle("fill", (x - 1) * TILE_SIZE + offset_x, (y - 1) * TILE_SIZE + offset_y, TILE_SIZE, TILE_SIZE)
                end
            end
        end

        love.graphics.setColor(1, 0, 0)
        for _, item in pairs(MAP_INFO.item_table) do
            love.graphics.rectangle("line", (item.x - 1) * TILE_SIZE, (item.y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end

        love.graphics.setColor(0, 1, 0)
        love.graphics.circle("fill", MOVEMENT.player_object.x, MOVEMENT.player_object.y, 15)

        local x_pos = MOVEMENT.player_object.x - 150
        local y_pos = MOVEMENT.player_object.y - 100
        love.graphics.setColor(1, 1, 1)
        for _, line in ipairs(inventory:print()) do
            love.graphics.print(line, x_pos, y_pos)
            y_pos = y_pos + 20
        end

    cam:detach()    
end

function onClick(x, y)
    for i, item in ipairs(MAP_INFO.item_table) do
        local tile_x = (item.x - 1) * TILE_SIZE
        local tile_y = (item.y - 1) * TILE_SIZE

        if x >= tile_x and x < tile_x + TILE_SIZE and y >= tile_y and y < tile_y + TILE_SIZE then
            MAP_INFO.destroyitem(map, item.x, item.y, inventory)
            return
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local worldX, worldY = cam:worldCoords(x, y)
        onClick(worldX, worldY)

        local tile_x = math.floor(worldX / TILE_SIZE) + 1
        local tile_y = math.floor(worldY / TILE_SIZE) + 1
        MAP_INFO.destroyitem(map, tile_x, tile_y, inventory)
    end
end
