
local inventory = {
    maxdefaultslots = 30,
    defaultsize = 30,
    inventory_arr = {},
    items = {
        [0] = {name = "Fist", dmg = 2},
        [10] = {name = "Small Rock", dmg = 1},
        [11] = {name = "Wood", dmg = 1},
    }
}

inventory.__index = inventory

function inventory.new(slots, slot_size)
    local self = setmetatable({}, inventory)
    self.maxslots = slots or inventory.maxdefaultslots
    self.slotsize = slot_size or inventory.defaultsize
    self.data = {}
    self.selected_item = 0

    for i = 1, self.maxslots do
        self.data[i] = {id = -1, amount = 0, name = ""}
    end
    
    table.insert(inventory.inventory_arr,self)

    return self
end

function inventory.get(index)
    if index > #inventory.inventory_arr then return end 
    return inventory.inventory_arr[index]
end

function inventory:add(itemid)
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
            slot.name = tostring(itemid)
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
            end
            return true
        end
    end
    return false
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

return inventory
