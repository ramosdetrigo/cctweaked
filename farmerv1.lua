local crop_db = require "crop_db"
local farmer = require "walker"
local u = require "utils"

farmer:extend({
    has_block_below = false,
    current_block = {},

    -- Turtle position in the crop field.
    pos = { x = 1, y = 1 },
    -- Turtle direction
    dir = { x = 1, y = 0 },
    -- Turtle target
    target = { x = 1, y = 1 },

    -- Chest position
    chest_pos = { x = -6, y = -18 },
    -- Field 1,1 location
    field_start = { x = -6, y = -19 },
    -- Field's opposite corner
    field_end = { x = -23, y = -27 },
    -- Field's direction
    field_dir = { x = -1, y = -1 },
})


-- Resets the farmer -> drops everything at the chest, moves to 1,1 and resets initial target
function farmer:reset()
    self:farmTo(self.chest_pos)
    self:dropInventory()
    self:farmTo(self.field_start)
    self.target = { x = self.field_end.x, y = self.field_start.y }
end


function farmer:run()
    self:inspectDown() -- starts current_block state
    self:syncDir()
    self:syncPos()
    self.field_dir = {
        x = u.sign(self.field_end.x - self.field_start.x),
        y = u.sign(self.field_end.y - self.field_start.y)
    }
    self:reset()


    -- Main farm loop
    while true do
    	-- moves to target while farming
        self:farmTo(self.target)

        -- changes the target to the other side of the field
        self.target.x = (self.target.x == self.field_start.x) and self.field_end.x or self.field_start.x
        -- moves 1 up the field in the y axis
        local dy = self.field_dir.y
        self.target.y = self.target.y + 1 * dy

        -- resets if we reached the end of the field
        if self.target.y * dy > self.field_end.y * dy then
            self:reset()
        end
    end
end

-- Moves to specified coords while farming
function farmer:farmTo(target)
    -- repeat until reaching target
    repeat
        self:inspectDown() -- updates block info
        if self.has_block_below then
            local crop_info = crop_db[self.current_block.name]
                -- Only farm if needed (crop might not be in db)
                local curr_age = self.current_block.state.age or 999
                if crop_info and curr_age >= crop_info.mature_age or (not crop_info) then
                    -- Only break if needed, else right click with hoe
                    self:farmDown(crop_info and crop_info.needs_breaking)
                end
            end
        -- get items below the farmer
        if self.current_block.name ~= "minecraft:chest" then
            self:suckDown(3)
        end
    until self:moveTorwards(target)
end

-- Updates block_below state
function farmer:inspectDown()
    self.has_block_below, self.current_block = turtle.inspectDown()
    -- Prevents errors finding strings when we expect tables
    if not self.has_block_below then
        self.current_block = { name = "nothing", state = {}, tags = {} }
    end
    return self.has_block_below, self.current_block
end

-- Farms using right click -> needs a hoe in slot 1
function farmer:farmDown(breaking)
    breaking = breaking or false
    turtle.select(1) -- Ensures slot 1 is selected
    if breaking then
        turtle.digDown()
    else
        turtle.placeDown()
    end
    print("Farmed" .. (self.current_block.name))
end

-- Sucks down items below the farmer a select amount of times. Defaults to 1 time.
function farmer:suckDown(times)
    times = times or 1
    for _ = 1, times do turtle.suckDown(); end
end

-- Drops the entire inventory of the turtle into the inventory below
function farmer:dropInventory()
    for i = 2, 16 do
        turtle.select(i)
        turtle.dropDown()
    end
    turtle.select(1)
end

-- Starts the farmer
print("Farmer starting!")
farmer:run()
