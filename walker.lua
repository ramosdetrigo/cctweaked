local u = require "utils"

local walker = {
    pos = { x = 0, y = 0 },
    dir = { x = 1, y = 0 },
}

-- Syncs the walker's position based on gps info
-- (REQUIRES MODEM)
function walker:syncPos()
    local x, _, y = gps.locate()
    self.pos.x = x
    self.pos.y = y
end

-- Syncs the walker's direction based on gps info
-- (REQUIRES MODEM)
function walker:syncDir()
    local x0, _, y0 = gps.locate()
    turtle.forward()
    local x1, _, y1 = gps.locate()
    turtle.back()
    self.dir = { x = x1 - x0, y = y1 - y0 }
end

-- Extends the walker's table
function walker:extend(t)
    for k, v in pairs(t) do
        self[k] = v
    end
end

-- Moves torwards the turtle's target by 1 step
-- returns true if at target
function walker:moveTorwards(target)
    -- Don't move if already at target
    if self:isPosition(target) then return true; end

    local dir = self:getDirectionTorwards(target)
    -- Aligns direction if necessary
    if not self:isDirection(dir) then
        local t = self:getClosestTurn(dir)
        self:turn(t)
    end
    self:forward()
    return false
end

-- Makes the turtle go to the specified coords
function walker:goTo(target)
    while not self:moveTorwards(target) do end
end

-- Checks if the walker is at position pos
function walker:isPosition(pos)
    return self.pos.x == pos.x and self.pos.y == pos.y
end

-- Checks if the walker's direction is the same as dir
function walker:isDirection(dir)
    return self.dir.x == dir.x and self.dir.y == dir.y
end

-- Finds the "normalized" turtle direction torwards a certain target
-- (closest coord component first)
function walker:getDirectionTorwards(target)
    local dx = target.x - self.pos.x
    local dy = target.y - self.pos.y

    -- move torwards the CLOSEST coordinate first
    if dy ~= 0 then
        return { x = 0, y = u.sign(dy) }
    else
        return { x = u.sign(dx), y = 0 }
    end
end

-- Finds the closest turn torwards a certain target
function walker:getClosestTurn(target_dir)
    if target_dir.x == -self.dir.x or target_dir.y == -self.dir.y then
        -- u-turn: turn twice
        return 2
    end

    -- right turn = -1, left turn = +1
    return -(target_dir.x * self.dir.y - target_dir.y * self.dir.x)
end

-- Walks forward updating position state
function walker:forward()
    turtle.forward()
    self.pos.x = self.pos.x + self.dir.x
    self.pos.y = self.pos.y + self.dir.y
end

-- negative number: turns N times to the left
-- positive number: turns N times to the right
function walker:turn(n)
    local fn = (n > 0) and self.turnRight or self.turnLeft
    for _ = 1, math.abs(n) do
        fn(self)
    end
end

-- Turns left updating direction state
function walker:turnLeft()
    local old_y = self.dir.y
    self.dir.y = -self.dir.x
    self.dir.x = old_y
    turtle.turnLeft()
end

-- Turns right updating direction state
function walker:turnRight()
    local old_y = self.dir.y
    self.dir.y = self.dir.x
    self.dir.x = -old_y
    turtle.turnRight()
end

return walker
