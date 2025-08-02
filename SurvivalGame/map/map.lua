local generator = require("map.generator")
local tiles = require("data.tiles")

local map = {
    tile_sz = 10,
    w = 2000,
    h = 2000,
}

map.tile_size = map.tile_sz
map.width = map.w
map.height = map.h
map.data = {}

function map.load(self)
    self.data = generator.generate(self.width, self.height,1)
end

function map.draw(self)
    for i = 1, self.height do
        for j = 1, self.width do
            local tile = self.data[i][j]
            local color = tiles[tile].color

            love.graphics.setColor(color)
            love.graphics.rectangle("fill", (j - 1) * self.tile_size, (i - 1) * self.tile_size, self.tile_size, self.tile_size)
        end
    end
end

return map
