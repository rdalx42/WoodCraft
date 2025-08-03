local MOVEMENT = require("player.movement")
local INVENTORY = require("player.inventory")
local MAP_INFO = require("map.generator")
local TILES = require("data.tiles")
local camera = require("libraries.camera")
local SPRITE = require("map.sprite_manager")
local UI = require("libraries.UI")

TILE_SIZE = 32
inventory = INVENTORY.new(30, 30)
local map = MAP_INFO.generate(200, 200, love.math.random(10, 1000))
cam = nil

function love.load()
    MOVEMENT.set_player({x = 500, y = 500}, 500)
    cam = camera()
    SPRITE.wind_shader({"tree"})
end

function love.update(dt)
    cam:lookAt(MOVEMENT.player_object.x, MOVEMENT.player_object.y)
    MOVEMENT.get(dt)
    UI.update(dt)
    SPRITE.update(dt)
    inventory:update(dt)
end

function love.draw()
    cam:attach()

    for y = 1, #map do
        for x = 1, #map[y] do
            local tile_id = map[y][x]
            local tile_info = TILES[tile_id]

            local offset_x, offset_y = 0, 0
            if tile_id == 10 or tile_id == 11 then
                local offset = MAP_INFO.getShakeOffset(x, y)
                offset_x = offset.x or 0
                offset_y = offset.y or 0
            end

            if tile_info then
                if tile_info.image then
                    local baseScale = TILE_SIZE / tile_info.image:getWidth()
                    local scale = baseScale
                
                    if tile_id == 1 then
                        scale = baseScale * 1.5
                    end
                
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

    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("fill", MOVEMENT.player_object.x, MOVEMENT.player_object.y, 15)

    local x_pos = MOVEMENT.player_object.x - 150
    local y_pos = MOVEMENT.player_object.y - 100
    love.graphics.setColor(1, 1, 1)
    local lines = inventory:print()
    if lines then
        for _, line in ipairs(lines) do
            love.graphics.print(line, x_pos, y_pos)
            y_pos = y_pos + 20
        end
    end

    SPRITE.draw_sprites()

    cam:detach()

    UI.draw()
    inventory:draw()
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local world_x, world_y = cam:worldCoords(x, y)
        SPRITE.click(world_x, world_y)
        inventory:mousepressed(x, y, button)
    end
end
