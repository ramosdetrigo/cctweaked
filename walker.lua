local u = require "utils"
local vec3 = require "vec3"

local walker = {
    pos = vec3(0,0,0),
    dir = vec3(1,0,0),
}

-- Syncs the walker's position based on gps info
-- (REQUIRES MODEM)
function walker:syncPos()
    self.pos = vec3(gps.locate())
end

-- Syncs the walker's direction based on gps info
-- (REQUIRES MODEM)
function walker:syncDir()
    turtle.dig()
    local v0 = vec3(gps.locate())
    turtle.forward()
    local v1 = vec3(gps.locate())
    turtle.back()
    self.dir = v1 - v0
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
    return self.pos == pos
end

-- Checks if the walker's direction is the same as dir
function walker:isDirection(dir)
    return self.dir == dir
end

-- Finds the "normalized" turtle direction torwards a certain target
-- (closest coord component first)
function walker:getDirectionTorwards(target)
    local dx = target.x - self.pos.x
    local dz = target.z - self.pos.z

    -- move torwards the CLOSEST coordinate first
    if dz ~= 0 then
        return vec3(0, 0, u.sign(dz))
    else
        return vec3(u.sign(dx), 0, 0)
    end
end

-- Finds the closest turn torwards a certain target
function walker:getClosestTurn(target_dir)
    -- u-turn: turn twice
    if target_dir == (self.dir * -1) then return 2; end
    -- right turn = -1, left turn = +1
    return -(target_dir.x * self.dir.z - target_dir.z * self.dir.x)
end


-- Walks forward updating position state
function walker:forward()
    turtle.forward()
    self.pos = self.pos + self.dir
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
    local old_z = self.dir.z
    self.dir.z = -self.dir.x
    self.dir.x = old_z
    turtle.turnLeft()
end

-- Turns right updating direction state
function walker:turnRight()
    local old_z = self.dir.z
    self.dir.z = self.dir.x
    self.dir.x = -old_z
    turtle.turnRight()
end

return walker
