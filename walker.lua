local u = require "utils"
local vec3 = require "vec3"

local walker = {
    pos = vec3(0, 0, 0),
    dir = vec3(1, 0, 0),
}

local abs = math.abs

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
---@param t table
function walker:extend(t)
    for k, v in pairs(t) do
        self[k] = v
    end
end

-- Moves torwards the turtle's target by 1 step
-- returns true if at target
---@param target vec3
---@return boolean # true if already at target false otherwise
function walker:moveTorwards(target)
    -- Don't move if already at target
    if self.pos == target then return true; end

    local dir = self:getDirectionTorwards(target)

    -- Edge case: vertical movement
    if dir.y < 0 then
        self:down()
        return false
    elseif dir.y > 0 then
        self:up()
        return false
    end

    -- Base case: Aligns direction if necessary then moves forward
    if self.dir ~= dir then
        local t = self:getClosestTurn(dir)
        self:turn(t)
    end
    self:forward()

    return false
end

-- Makes the turtle go to the specified coords
---@param target vec3
function walker:goTo(target)
    repeat until self:moveTorwards(target)
end

-- Finds the "normalized" turtle direction torwards a certain target
-- (closest coord component first)
---@param target vec3
function walker:getDirectionTorwards(target)
    local dv = target - self.pos
    local dv_abs = dv:abs()

    if dv_abs.x >= dv_abs.y and dv_abs.x >= dv_abs.z then
        return vec3(u.sign(dv.x), 0, 0)
    elseif dv_abs.y >= dv_abs.x and dv_abs.y >= dv_abs.z then
        return vec3(0, u.sign(dv.y), 0)
    else
        return vec3(0, 0, u.sign(dv.z))
    end
end

-- Finds the closest turn torwards a certain target
---@param target_dir vec3
---@return number turns
function walker:getClosestTurn(target_dir)
    -- u-turn: turn twice
    if target_dir == (self.dir * -1) then return 2; end
    -- right turn = -1, left turn = +1
    return -(target_dir.x * self.dir.z - target_dir.z * self.dir.x)
end

-- Functions to walk updating position state
function walker:forward()
    turtle.forward()
    self.pos = self.pos + self.dir
end

function walker:back()
    turtle.back()
    self.pos = self.pos - self.dir
end

function walker:up()
    turtle.up()
    self.pos.y = self.pos.y + 1
end

function walker:down()
    turtle.up()
    self.pos.y = self.pos.y - 1
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

-- negative number: turns N times to the left
-- positive number: turns N times to the right
---@param n number
function walker:turn(n)
    local fn = (n > 0) and self.turnRight or self.turnLeft
    for _ = 1, math.abs(n) % 4 do
        fn(self)
    end
end

return walker
