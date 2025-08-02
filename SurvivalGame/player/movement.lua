
local movement = {
    movement_keys = {"w","a","s","d","up","down","left","right"},

    player_object = {x = 0, y = 0, sprite = nil, speed = 100},
}

local moveUp = function(self, dt) self.player_object.y = self.player_object.y - (self.player_object.speed or 200) * dt end
local moveLeft = function(self, dt) self.player_object.x = self.player_object.x - (self.player_object.speed or 200) * dt end
local moveDown = function(self, dt) self.player_object.y = self.player_object.y + (self.player_object.speed or 200) * dt end
local moveRight = function(self, dt) self.player_object.x = self.player_object.x + (self.player_object.speed or 200) * dt end

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

function movement.set_player(object,speed)
    movement.player_object.speed = speed or 200
    movement.player_object.sprite = object.sprite
    movement.player_object.x = object.x
    movement.player_object.y = object.y
end

function movement.get(dt)
    for _, key in ipairs(movement.movement_keys) do
        if love.keyboard.isDown(key) then
            if movement.key_bindings[key] then
                movement.key_bindings[key](movement, dt)
            end
        end
    end
end

return movement
