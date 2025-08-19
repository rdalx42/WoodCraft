local sprite_manager = {
    sprite_info = {
        ["smallrock"] = {
            hp = 4,
            returntype = 10,
            hitboxX = 30,
            hitboxY = 30,
            spawninterval1 = 0.0,
            spawninterval2 = 0.05,
            compatible = {1,3,5,9,8,4},
            height_multiplier = 1,
            can_grab = false,
            droppable_while_hit = 0,
            droppable_while_hit_interval1 = 0,
            droppable_while_hit_interval2 = 0.1,
            hover_enabled=false,
        },
        ["tree"] = {
            hp = 4,
            returntype = 11,
            hitboxX = 30,
            hitboxY = 50,
            spawninterval1 = 0.0,
            spawninterval2 = 0.05,
            compatible = {1,3,9,11},
            height_multiplier = 2,
            can_grab = false,
            droppable_while_hit = 12,
            droppable_while_hit_interval1 = 0,
            droppable_while_hit_interval2 = 0.1,
            hover_enabled=false,
            
        },
        ["leaf"] = {
            hp = 0,
            returntype = 12,
            hitboxX = 30,
            hitboxY = 30,
            spawninterval1 = 0.0,
            spawninterval2 = 0.0,
            compatible = {1,3,9,11},
            height_multiplier = 1,
            can_grab = true,
            droppable_while_hit = 0,
            droppable_while_hit_interval1 = 0,
            droppable_while_hit_interval2 = 0.1,
            hover_enabled=true,
            
        },
        ["wood"] = {
            hp = 0,
            returntype = 11,
            hitboxX = 30,
            hitboxY = 30,
            spawninterval1 = 0.0,
            spawninterval2 = 0.0,
            compatible = {1,3,9,11},
            height_multiplier = 1,
            can_grab = true,
            droppable_while_hit = 0,
            droppable_while_hit_interval1 = 0,
            droppable_while_hit_interval2 = 0.1,
            hover_enabled=true,
            
        },

        ["rock"] = {
            hp = 0,
            returntype = 10,
            hitboxX = 30,
            hitboxY = 30,
            spawninterval1 = 0.0,
            spawninterval2 = 0.0,
            compatible = {1,3,9,11},
            height_multiplier = 1,
            can_grab = true,
            droppable_while_hit = 0,
            droppable_while_hit_interval1 = 0,
            droppable_while_hit_interval2 = 0.1,
            hover_enabled=true,
        }
    },
    
    existing_sprites = { "rock","smallrock", "tree", "leaf","wood"},
    sprites = {},
    animation_time = 0.15
}

function sprite_manager.wind_shader(names)
    for i = 1, #sprite_manager.sprites do
        local child = sprite_manager.sprites[i]
        for j = 1, #names do
            if names[j] == child.name then
                child.wind_enabled = true
                break
            end
        end
    end
end

function sprite_manager.hover_shader(names)
    for i = 1, #sprite_manager.sprites do
        local child = sprite_manager.sprites[i]
        for j = 1, #names do
            if names[j] == child.name then
                child.hover_enabled = true
                child.hover_timer = 0 -- initialize if not already there
                break
            end
        end
    end
end


function sprite_manager.draw_hitboxes()
    for _, sprite in ipairs(sprite_manager.sprites) do
        local hitbox_x = sprite.x * TILE_SIZE
        local hitbox_y = sprite.y * TILE_SIZE
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("fill", hitbox_x, hitbox_y, sprite.hitbox_x, sprite.hitbox_y)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function sprite_manager.aabb_collision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

function sprite_manager.check_player_collision(newX, newY, playerWidth, playerHeight)
    for i = 1, #sprite_manager.sprites do
        local sprite = sprite_manager.sprites[i]
        local info = sprite_manager.sprite_info[sprite.name]
        local hitbox_x = sprite.x * TILE_SIZE + (TILE_SIZE - sprite.hitbox_x) / 2
        local hitbox_y = sprite.y * TILE_SIZE + (TILE_SIZE * info.height_multiplier - sprite.hitbox_y) / 2 + sprite.offset_y_anim
        if sprite_manager.aabb_collision(newX, newY, playerWidth, playerHeight, hitbox_x, hitbox_y, sprite.hitbox_x, sprite.hitbox_y) then
            return true
        end
    end
    return false
end


function sprite_manager.can_spawn(x, y, name, below)
    local info = sprite_manager.sprite_info[name]
    if info then
        for i = 1, #info.compatible do 
            if below == info.compatible[i] then 
                local chance = love.math.random()
                if chance >= info.spawninterval1 and chance <= info.spawninterval2 then
                    return true
                end
                break
            end
        end
        return false
    end
    return false
end

function sprite_manager.load_sprite(x, y, name, can_grab)
    local info = sprite_manager.sprite_info[name]
    if not info then return end

    local image = love.graphics.newImage("assets/sprites/" .. name .. ".png")
    local img_width = image:getWidth()
    local img_height = image:getHeight()
    local scale_x = TILE_SIZE / img_width
    local scale_y = TILE_SIZE * sprite_manager.sprite_info[name].height_multiplier / img_height
    local offset_center_x = (TILE_SIZE - img_width * scale_x) / 2
    local offset_center_y = (TILE_SIZE - img_height * scale_y) / 2

    local sprite = {
        x = x,
        y = y,
        id = #sprite_manager.sprites + 1,
        hitbox_x = info.hitboxX,
        hitbox_y = info.hitboxY,
        name = name,
        can_grab = can_grab or false,
        image = image,
        returntype = info.returntype,
        scale_x = scale_x,
        scale_y = scale_y,
        anim_timer = 0,
        offset_x = offset_center_x,
        offset_y = offset_center_y,
        offset_y_anim = 0,
        hp = info.hp,
        wind_angle = 0,
        wind_timer = love.math.random() * math.pi * 2,
        wind_enabled = false,
        hit_wobble_timer = 0
    }

    table.insert(sprite_manager.sprites, sprite)
end

function sprite_manager.update(dt)
    for _, sprite in ipairs(sprite_manager.sprites) do
        if sprite.anim_timer > 0 then
            sprite.anim_timer = sprite.anim_timer - dt
            local phase = (sprite.anim_timer / sprite_manager.animation_time) * math.pi * 2
            sprite.offset_y_anim = math.sin(phase) * 3
        else
            sprite.offset_y_anim = 0
        end

        if sprite.wind_enabled then
            sprite.wind_timer = sprite.wind_timer + dt
            sprite.wind_angle = math.sin(sprite.wind_timer * 2) * 0.05
        else
            sprite.wind_angle = 0
        end

        if sprite.hit_wobble_timer > 0 then
            sprite.hit_wobble_timer = sprite.hit_wobble_timer - dt
            sprite.wind_angle = sprite.wind_angle + math.sin(sprite.hit_wobble_timer * 40) * 0.1
        end

        if sprite.hover_enabled then
            sprite.hover_timer = (sprite.hover_timer or 0) + dt
            sprite.offset_y_anim = math.sin(sprite.hover_timer * 2) * 2
        else
            sprite.offset_y_anim = 0
        end
    end
end

function sprite_manager.draw_sprites()
    for _, sprite in ipairs(sprite_manager.sprites) do
        local draw_x = sprite.x * TILE_SIZE + sprite.offset_x
        local draw_y = sprite.y * TILE_SIZE + sprite.offset_y + sprite.offset_y_anim
        love.graphics.draw(
            sprite.image,
            draw_x + sprite.image:getWidth() * sprite.scale_x / 2,
            draw_y + sprite.image:getHeight() * sprite.scale_y / 2,
            sprite.wind_angle,
            sprite.scale_x,
            sprite.scale_y,
            sprite.image:getWidth() / 2,
            sprite.image:getHeight() / 2
        )
    end
end

function sprite_manager.destroy(idval)
    for i = #sprite_manager.sprites, 1, -1 do
        if sprite_manager.sprites[i].id == idval then
            table.remove(sprite_manager.sprites, i)
            break
        end
    end
    for i, sprite in ipairs(sprite_manager.sprites) do
        sprite.id = i
    end
end

function sprite_manager.click(x, y)
    local INVENTORY = require("player.inventory")
    for _, sprite in ipairs(sprite_manager.sprites) do
        local draw_x = sprite.x * TILE_SIZE + sprite.offset_x - 2
        local draw_y = sprite.y * TILE_SIZE + sprite.offset_y + sprite.offset_y_anim
        local hitbox_left = draw_x
        local hitbox_top = draw_y
        local hitbox_right = hitbox_left + sprite.hitbox_x
        local hitbox_bottom = hitbox_top + sprite.hitbox_y

        if x >= hitbox_left and x <= hitbox_right and y >= hitbox_top and y <= hitbox_bottom then
            local selected_item_id = inventory.selected_item
            local damage = 0

            print(selected_item_id)
            if INVENTORY.items[selected_item_id] then
                -- here's the bug with the rock.
                damage = INVENTORY.items[selected_item_id].dmg or 0
                print("found")
            end

            local prevhp = sprite.hp

            sprite.hp = sprite.hp - damage
            sprite.hit_wobble_timer = 0.2

            local info = sprite_manager.sprite_info[sprite.name]
            local destroyed = false

            if not destroyed then
                if info.droppable_while_hit and not (prevhp == sprite.hp) then
                    local drop_chance = love.math.random()
                    if drop_chance >= info.droppable_while_hit_interval1 and drop_chance <= info.droppable_while_hit_interval2 then
                        inventory:add(info.droppable_while_hit)
                    end
                end

                if sprite.hp <= 0 then
                    inventory:add(sprite.returntype)
                    sprite_manager.destroy(sprite.id)
                end
            end

            break
        end
    end
end

return sprite_manager
