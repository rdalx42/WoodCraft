local MOVEMENT = require("player.movement")
local INVENTORY = require("player.inventory")
local MAP_INFO = require("map.generator")
local TILES = require("data.tiles")
local camera = require("libraries.camera")
local SPRITE = require("map.sprite_manager")
local UI = require("libraries.UI")
local WEATHER = require("map.weather")

TILE_SIZE = 32
inventory = INVENTORY.new(30, 30)
local map = MAP_INFO.generate(200, 200, love.math.random(10, 1000))
cam = nil

local particle_system = nil

function setup_particle(data)
    if data.particle_img ~= "" then
        local img = love.graphics.newImage(data.particle_img)
        if not particle_system or particle_system:getTexture() ~= img then
            
            local min_angle = data.angle_min or 0
            local max_angle = data.angle_max or 0
            
            local direction = math.rad((min_angle + max_angle) / 2)
            local spread = math.rad(math.abs(max_angle - min_angle) / 2)
            
            particle_system = love.graphics.newParticleSystem(img, 1000)
            particle_system:setEmitterLifetime(-1)
            particle_system:setParticleLifetime(5, 10)
            particle_system:setSizeVariation(1)
            particle_system:setSizes(1.5, 2.5)
            
            particle_system:setDirection(direction)  
            particle_system:setSpread(spread)       
            
            particle_system:setLinearAcceleration(-20, 200, 20, 400)
            particle_system:setColors(1, 1, 1, 1, 1, 1, 1, 0)
            particle_system:setEmissionArea("uniform", love.graphics.getWidth(), 0)
        end
        particle_system:setEmissionRate(data.emission_rate)
        particle_system:start()
    end
end


function love.load()
   
    MOVEMENT.set_player({x = 500, y = 500}, 500)
    cam = camera()
    SPRITE.wind_shader({"tree"})
end

function love.update(dt)
    WEATHER.update(dt)
    cam:lookAt(MOVEMENT.player_object.x, MOVEMENT.player_object.y)
    MOVEMENT.get(dt)
    UI.update(dt)
    SPRITE.update(dt)
    inventory:update(dt)
    if particle_system then
        particle_system:update(dt)
    end

end

function love.draw()
    cam:attach()

    -- Draw only visible tiles for performance (example)
    local screen_w, screen_h = love.graphics.getWidth(), love.graphics.getHeight()
    local cam_x, cam_y = cam.x, cam.y
    local start_x = math.max(1, math.floor((cam_x - screen_w / 2) / TILE_SIZE))
    local end_x = math.min(#map[1], math.ceil((cam_x + screen_w / 2) / TILE_SIZE))
    local start_y = math.max(1, math.floor((cam_y - screen_h / 2) / TILE_SIZE))
    local end_y = math.min(#map, math.ceil((cam_y + screen_h / 2) / TILE_SIZE))

    for y = start_y, end_y do
        for x = start_x, end_x do
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

    if particle_system then
        local sw = love.graphics.getWidth()
        love.graphics.draw(particle_system, sw / 2, 0)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local world_x, world_y = cam:worldCoords(x, y)
        SPRITE.click(world_x, world_y)
        inventory:mousepressed(x, y, button)
    end
end
