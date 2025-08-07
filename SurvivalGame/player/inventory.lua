local UI = require("libraries.ui")
local SPRITE = require("map.sprite_manager")
local HELPER = require("libraries.helper")
local MOVEMENT = require("player.movement")

local inventory = {
    maxdefaultslots = 30,
    defaultsize = 30,
    inventory_arr = {},
    items = {
        [0] = {name = "Fist", dmg = 2,img=nil},
        [10] = {name = "rock", dmg = 2,img=nil},
        [11] = {name = "Wood", dmg = 2,img=nil},
        [12] = {name = "Leaf", dmg = 0,img=nil},
        
    },
    visible = false,
    toggleCooldown = 0.2,
    toggleTimer = 0,
}

inventory.__index = inventory

local function get_img()
    for id, item in pairs(inventory.items) do 
        local success, img_or_err = pcall(love.graphics.newImage, "assets/sprites/" .. item.name .. ".png")
        if success then 
            inventory.items[id].img = img_or_err
        else
            print("Failed to load image for item:", item.name, img_or_err)
        end
    end
end

function inventory.new(slots, slot_size)
    get_img()
    local self = setmetatable({}, inventory)
    self.maxslots = slots or inventory.maxdefaultslots
    self.slotsize = slot_size or inventory.defaultsize
    self.data = {}
    self.selected_item = 0

    for i = 1, self.maxslots do
        self.data[i] = {id = -1, amount = 0, name = "", dropname = ""}
    end    
    
    for id,item in pairs(self.items) do 
        if item.name then 
            local path = "assets/"..string.lower(item.name)
        end
    end

    self.uiFrame = UI.newFrame("InventoryFrame", 100, 100, 400, 300)
    self.uiFrame:hide()

    table.insert(inventory.inventory_arr, self)
    return self
end

function inventory.swap(slotA, slotB)
    local temp = {
        id = slotA.id,
        amount = slotA.amount,
        name = slotA.name,
        dropname = slotA.dropname
    }

    slotA.id = slotB.id
    slotA.amount = slotB.amount
    slotA.name = slotB.name
    slotA.dropname = slotB.dropname

    slotB.id = temp.id
    slotB.amount = temp.amount
    slotB.name = temp.name
    slotB.dropname = temp.dropname
end

function inventory.get(index)
    if index > #inventory.inventory_arr then return end 
    return inventory.inventory_arr[index]
end

function inventory:add(itemid)
    local item = inventory.items[itemid]
    local itemname = item and item.name:lower() or tostring(itemid)

    for i = 1, self.maxslots do
        local slot = self.data[i]
        if slot.id == itemid and slot.amount < self.slotsize then
            slot.amount = slot.amount + 1
            return true
        end
    end

    for i = 1, self.maxslots do
        local slot = self.data[i]
        if slot.id == -1 then
            slot.id = itemid
            slot.amount = 1
            slot.name = itemname
            slot.dropname = itemname
            return true
        end
    end

    return false
end

function inventory:remove(itemid)
    for i = 1, self.maxslots do
        local slot = self.data[i]
        if slot.id == itemid then
            slot.amount = slot.amount - 1
            if slot.amount <= 0 then
                slot.id = -1
                slot.amount = 0
                slot.name = ""
                slot.dropname = ""
            end
            return true
        end
    end
    return false
end

function inventory:remove_at(index)
    if index > self.maxslots then return end
    local slot = self.data[index]
    if slot.id == -1 then return end

    slot.amount = slot.amount - 1
    if slot.amount <= 0 then
        slot.id = -1
        slot.name = ""
        slot.dropname = ""
        slot.amount = 0
    end
end

function inventory:print()
    local lines = {}
    for i = 1, self.maxslots do
        local slot = self.data[i]
        if slot.id ~= -1 then
            table.insert(lines, string.format("Slot %d: %s x%d", i, slot.id, slot.amount))
        end
    end
    return lines
end

function inventory:update(dt)
    
    self.toggleTimer = self.toggleTimer - dt
    if love.keyboard.isDown("tab") and self.toggleTimer <= 0 then
        self.visible = not self.visible
        self.toggleTimer = self.toggleCooldown

        if self.visible then
            self.uiFrame:show()
        else
            self.uiFrame:hide()
        end
    end

    self.selected_item = 0
    if self.data[1].id ~= -1 then
        self.selected_item = self.data[1].id
        if inventory.items[self.selected_item] and inventory.items[self.selected_item].img then 
            MOVEMENT.set_tool(inventory.items[self.selected_item].img)
        end
    else 
        MOVEMENT.set_tool(nil)    
    end

    local playerX = MOVEMENT.player_object.x
    local playerY = MOVEMENT.player_object.y
    local playerW = MOVEMENT.player_object.w or 30
    local playerH = MOVEMENT.player_object.h or 30

    for i = 1, #SPRITE.sprites do
        
        local sprite = SPRITE.sprites[i]
        local info = SPRITE.sprite_info[string.lower(sprite.name)]
        if info and info.can_grab then
           -- print("exists")
            local hitboxX = sprite.x * TILE_SIZE + (TILE_SIZE - info.hitboxX) / 2
            local hitboxY = sprite.y * TILE_SIZE + (TILE_SIZE * info.height_multiplier - info.hitboxY) / 2 + sprite.offset_y_anim
            local hitboxW = info.hitboxX
            local hitboxH = info.hitboxY

            if SPRITE.aabb_collision(playerX, playerY, playerW, playerH, hitboxX, hitboxY, hitboxW, hitboxH) then
                
                
                local item_name = string.lower(sprite.name)
                local selected_item_id = nil

                for id, item in pairs(inventory.items) do
                    if string.lower(item.name) == item_name then
                        selected_item_id = id
                        break
                    end
                end

                if selected_item_id then
                    self:add(selected_item_id)
                    SPRITE.destroy(sprite.id)

                    if self.data[1].id ~= -1 then
                        self.selected_item = self.data[1].id
                        
    
                    end
                    
                    return 
                end
            end
           
        end
    end

end

function inventory:draw()
    if not self.visible then return end

    local cols = 10
    local spacing = 5
    local startX, startY = self.uiFrame.x + 130, self.uiFrame.y + 10
    local mx, my = love.mouse.getPosition()

    local hoveredSlot = nil
    

    for i = 1, self.maxslots do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x = startX + col * (self.slotsize + spacing)
        local y = startY + row * (self.slotsize + spacing)

        love.graphics.setColor(i == 1 and {1, 0, 0, 0.5} or {0.2, 0.2, 0.2})
        love.graphics.rectangle("fill", x, y, self.slotsize, self.slotsize)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x, y, self.slotsize, self.slotsize)

        local slot = self.data[i]
        if slot.id ~= -1 then
            local item = inventory.items[slot.id]
            local name = item and item.name or tostring(slot.id)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(name .. " x" .. slot.amount, x + 2, y + self.slotsize / 2 - 6, self.slotsize - 4, "center")
        end

        if self.swap_item1 == i then
            love.graphics.setColor(1, 1, 0)
            love.graphics.rectangle("line", x - 2, y - 2, self.slotsize + 4, self.slotsize + 4)
        end

        if mx >= x and mx <= x + self.slotsize and my >= y and my <= y + self.slotsize then
            hoveredSlot = slot
        end
    end

    if hoveredSlot and hoveredSlot.id ~= -1 then
        local item = inventory.items[hoveredSlot.id]
        local tooltipText = item and item.bio or tostring("x" .. hoveredSlot.amount)
        local padding = 5
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(tooltipText)
        local textHeight = font:getHeight()
        local tooltipX = mx + 15
        local tooltipY = my + 15

        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", tooltipX - padding, tooltipY - padding, textWidth + 2 * padding, textHeight + 2 * padding)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(tooltipText, tooltipX, tooltipY)
    end
end

function inventory:rightmousepressed(x, y, button)
    if not self.visible then return end

    local cols = 10
    local spacing = 5
    local startX, startY = self.uiFrame.x + 130, self.uiFrame.y + 10

    for i = 1, self.maxslots do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local slotX = startX + col * (self.slotsize + spacing)
        local slotY = startY + row * (self.slotsize + spacing)
        local size = self.slotsize

        if x >= slotX and x <= slotX + size and y >= slotY and y <= slotY + size then
            local slot = self.data[i]
            if slot.id == -1 then return end

            if HELPER.find(SPRITE.existing_sprites, slot.dropname) then
                local playerX = MOVEMENT.player_object.x
                local playerY = MOVEMENT.player_object.y
                local tileX = math.floor(playerX / TILE_SIZE) + 1
                local tileY = math.floor(playerY / TILE_SIZE) + 1
                SPRITE.load_sprite(tileX + love.math.random(0, 1.5), tileY + love.math.random(0, 1.5), slot.dropname, true)
            end

            self:remove_at(i)
            return
        end
    end
end

function inventory:mousepressed(x, y, button)
    if not self.visible then
        self.swap_item1 = nil
        return
    end

    local cols = 10
    local spacing = 5
    local startX, startY = self.uiFrame.x + 130, self.uiFrame.y + 10

    for i = 1, self.maxslots do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local slotX = startX + col * (self.slotsize + spacing)
        local slotY = startY + row * (self.slotsize + spacing)
        local size = self.slotsize

        if x >= slotX and x <= slotX + size and y >= slotY and y <= slotY + size then
            if self.swap_item1 == nil then
                self.swap_item1 = i
            else
                self.swap_item2 = i
                if self.swap_item1 ~= self.swap_item2 then
                    local slot1 = self.data[self.swap_item1]
                    local slot2 = self.data[self.swap_item2]
                    inventory.swap(slot1, slot2)
                end
                self.swap_item1 = nil
                self.swap_item2 = nil
            end
            return
        end
    end
    self.swap_item1 = nil
end

return inventory
