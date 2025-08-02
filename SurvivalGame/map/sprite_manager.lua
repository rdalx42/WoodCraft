local INVENTORY = require("player.inventory")

local sprite_manager = {
    sprite_info = {
        ["smallrock"] = {
            hp = 4,
            returntype = 10,
            hitboxX = 30,
            hitboxY = 30,
            spawninterval1 = 0.0,
            spawninterval2 = 0.1,
            compatible = 5,
            height_multiplier=1,
        },

        ["tree"] = {
            hp = 4,
            returntype = 11,
            hitboxX = 30,
            hitboxY = 60,
            spawninterval1 = 0.0,
            spawninterval2 = 0.1,
            compatible = 1,
            height_multiplier=2,
        }
    },
    existing_sprites = {"smallrock","tree"},
    sprites = {},
    animation_time = 0.15
}

function sprite_manager.can_spawn(x, y, name, below)
    local info = sprite_manager.sprite_info[name]
    if info and below == info.compatible then
        local chance = love.math.random()
        if chance >= info.spawninterval1 and chance <= info.spawninterval2 then
            return true
        end
    end
    return false
end

function sprite_manager.load_sprite(x, y, name)
    local info = sprite_manager.sprite_info[name]
    if not info then return end

    local image = love.graphics.newImage("assets/sprites/" .. name .. ".png")
    local img_width = image:getWidth()
    local img_height = image:getHeight()
    local scale_x = TILE_SIZE / img_width
    local scale_y = TILE_SIZE*sprite_manager.sprite_info[name].height_multiplier / img_height
    local offset_center_x = (TILE_SIZE - img_width * scale_x) / 2
    local offset_center_y = (TILE_SIZE - img_height * scale_y) / 2

    local sprite = {
        x = x,
        y = y,
        id = #sprite_manager.sprites + 1,
        hitbox_x = info.hitboxX,
        hitbox_y = info.hitboxY,
        name = name,
        image = image,
        returntype = info.returntype,
        scale_x = scale_x,
        scale_y = scale_y,
        anim_timer = 0,
        offset_x = offset_center_x,
        offset_y = offset_center_y,
        offset_y_anim = 0,
        hp = info.hp  
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
    end
end

function sprite_manager.draw_sprites()
    for _, sprite in ipairs(sprite_manager.sprites) do
        local draw_x = sprite.x * TILE_SIZE + sprite.offset_x
        local draw_y = sprite.y * TILE_SIZE + sprite.offset_y + sprite.offset_y_anim
        love.graphics.draw(sprite.image, draw_x, draw_y, 0, sprite.scale_x, sprite.scale_y)
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
            if INVENTORY.items[selected_item_id] then
                damage = INVENTORY.items[selected_item_id].dmg or 0
            end

            sprite.hp = sprite.hp - damage

            if sprite.hp <= 0 then
                inventory:add(sprite.returntype)
                sprite_manager.destroy(sprite.id)
            end

            break 
        end
    end
end

return sprite_manager
