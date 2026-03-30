---@class vec3
---@field x number
---@field y number
---@field z number
local vec3 = {}

vec3.__index = vec3


---@constructor
---@param x number
---@param y number
---@param z number
function vec3:__call(x, y, z)
    return setmetatable({ x = x, y = y, z = z }, self)
end

function vec3:hash()
    return self.x .. "|" .. self.y .. "|" .. self.z
end

---@param rhs vec3
function vec3:add(rhs)
    return vec3(self.x + rhs.x, self.y + rhs.y, self.z + rhs.z)
end

vec3.__add = vec3.add


---@param rhs vec3
function vec3:sub(rhs)
    return vec3(self.x - rhs.x, self.y - rhs.y, self.z - rhs.z)
end

vec3.__sub = vec3.sub


---@overload fun(self: number, scalar: vec3): vec3
---@overload fun(self: vec3, scalar: number): vec3
---@overload fun(self: vec3, scalar: vec3): vec3
function vec3:mul(scalar)
    if type(self) == "table" and type(scalar) == "table" then
        return vec3(self.x * scalar.x, self.y * scalar.y, self.z * scalar.z)
    end
    if type(self) == "number" then
        self, scalar = scalar, self
    end
    return vec3(self.x * scalar, self.y * scalar, self.z * scalar)
end

vec3.__mul = vec3.mul


---@param scalar number
function vec3:div(scalar)
    return vec3(self.x / scalar, self.y / scalar, self.z / scalar)
end

vec3.__div = vec3.div


---@param rhs vec3
function vec3:eq(rhs)
    return self.x == rhs.x and self.y == rhs.y and self.z == rhs.z
end

vec3.__eq = vec3.eq


function vec3:__unm()
    return vec3(-self.x, -self.y, -self.z)
end

function vec3:rotate90Left()
    return vec3(self.z, self.y, -self.x)
end

function vec3:rotate90Right()
    return vec3(-self.z, self.y, self.x)
end

---@param n number
function vec3:rotate90(n)
    local fn = (n > 0) and self.rotate90Right or self.rotate90Left
    local v = self
    for _ = 1, math.abs(n) do
        v = fn(v)
    end
    return v
end

setmetatable(vec3, vec3)

return vec3
