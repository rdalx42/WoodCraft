local SRPITE = require("map.sprite_manager")

local movement = {
    movement_keys = {"w","a","s","d","up","down","left","right"},

    player_object = {x = 0, y = 0, sprite = nil, speed = 400, width=16, height=16},
    tool_object = {offset_x = 0,offset_y = 0,x = 0,y = 0,sprite = nil},
    tobj_sprite = love.graphics.newImage("assets/sprites/leaf.png")
}

local moveUp = function(self, dt)
    return self.player_object.x, self.player_object.y - (self.player_object.speed or 200) * dt
end
local moveLeft = function(self, dt)
    return self.player_object.x - (self.player_object.speed or 200) * dt, self.player_object.y
end
local moveDown = function(self, dt)
    return self.player_object.x, self.player_object.y + (self.player_object.speed or 200) * dt
end
local moveRight = function(self, dt)
    return self.player_object.x + (self.player_object.speed or 200) * dt, self.player_object.y
end

movement.input_lambdas = {
    moveUp = moveUp,
    moveLeft = moveLeft,
    moveDown = moveDown,
    moveRight = moveRight,
}

movement.key_bindings = {
    w = moveUp,
    up = moveUp,

    a = moveLeft,
    left = moveLeft,

    s = moveDown,
    down = moveDown,

    d = moveRight,
    right = moveRight,
}

function movement.get_orientation()
    
    local mx, my = love.mouse.getPosition()
    local wx, wy = cam:worldCoords(mx,my)
    local dx = wx-movement.player_object.x 
    local dy = wy-movement.player_object.y 
    local angle = math.atan2(dy,dx)
    local r = 30

    movement.tool_object.x = movement.player_object.x+math.cos(angle)*r 
    movement.tool_object.y=movement.player_object.y+math.sin(angle)*r 
    movement.tool_object.angle=angle
end

function movement.set_tool(img)

    if not img then 
        movement.tobj_sprite=love.graphics.newImage("assets/sprites/TRANSPARENT.png") -- placeholder for images when we find an item without an image
    else
        movement.tobj_sprite=img 
    end
    movement.tool_object.sprite = movement.tobj_sprite
    movement.tool_object.offset_x = 0
    movement.tool_object.offset_y = 0
end

function movement.set_player(object, speed)
    movement.player_object.speed = speed or 200
    movement.player_object.sprite = object.sprite
    movement.player_object.x = object.x
    movement.player_object.y = object.y
    movement.tool_object.sprite = movement.tobj_sprite
    movement.tool_object.x=movement.player_object.x 
    movement.tool_object.y=movement.player_object.y
end

function movement.get(dt)
    local player = movement.player_object
    
    for _, key in ipairs(movement.movement_keys) do
        if love.keyboard.isDown(key) and movement.key_bindings[key] then
            local newX, newY = movement.key_bindings[key](movement, dt)

            if not SRPITE.check_player_collision(newX, newY, player.width, player.height) then
                player.x = newX
                player.y = newY
            end
        end
    end
end

return movement
