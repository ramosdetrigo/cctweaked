local miner = require("walker")
local utils = require("utils")
local vec3 = require("vec3")

miner:extend({
	layer = 0,
	refuel_with_lava = false,
	clear_trash_treshold = 10,

	target = vec3(0, 0, 0),
	trash_counter = 0,

	home_pos = vec3(0, 0, 0),
	chest_pos = vec3(0, 0, 0),

	field_start = vec3(0, 0, 0),
	field_end = vec3(0, 0, 0),
	field_dir = vec3(0, 0, 0),
})

function miner:mineVein(start)
	local stack = {} -- block stack
	local found = {} -- found blocks hashmap

	stack[#stack + 1] = start
	found[start:hash()] = true

	-- Depth-first algorithm
	while #stack ~= 0 do
		local block = stack[#stack]
		self:mineTo(block) -- visits block

		-- finds non-visited neighbour
		local neighbour
		for n in self:neighbourOres() do
			if found[n:hash()] then
				neighbour = n
				break
			end
		end

		if neighbour then
			-- if found, adds neighbour to the top of the stack
			stack[#stack + 1] = neighbour
			found[neighbour:hash()] = true
		else
			-- else, pops the stack
			table.remove(stack, #stack)
		end
	end
end

function miner:reset()
	self:moveTorwards(self.home_pos)
	self:moveTorwards(self.chest_pos)
	self:dropInventory()
	self:moveTorwards(self.home_pos)
	self.target = vec3(self.field_end.x, self.field_start.y, self.field_start.z)
end

function miner:run()
	self:syncDir()
	self:syncPos()
	self.field_dir = vec3(
		utils.sign(self.field_end.x - self.field_start.x),
		utils.sign(self.field_end.y - self.field_start.y),
		utils.sign(self.field_end.z - self.field_start.z)
	)
	self:reset()

	while true do
		self:mineTo(self.target)

		self.trash_counter = self.trash_counter + 1
		if self.trash_counter > self.clear_trash_treshold then
			-- TODO: clear inventory
		end

		self.target.x = (self.target.x == self.field_start.x) and self.field_end.x or self.field_start.x

		local dz = self.field_dir.z
		self.target.z = self.target.z + 1 * dz

		if self.target.z * dz > self.field_end.z * dz then
			self:reset()
		end
	end
	-- ++conter trash
	-- ++conter fuel
end

---comment
---@param target vec3
function miner:mineTo(target)
	repeat
		local dir = self:getDirectionTorwards(target)

		if dir.y < 0 then
			self:digDown()
		elseif dir.y > 0 then
			self:digUp()
		else
			if self.dir ~= dir then
				local t = self:getClosestTurn(dir)
				self:turn(t)
			end
			self:dig()
		end
	until self:moveTorwards(target)
end

function miner:mineDown()
	turtle.digDown()
	self:down()
end

function miner:mineUp()
	turtle.digUp()
	self:up()
end

function miner:mineForward()
	turtle.dig()
	self:forward()
end

function miner:mineBackward()
	self:turn(-2)
	turtle.dig()
	self:forward()
end

function miner:dropInventory()
	for i = 1, 16 do
		turtle.select(i)
		turtle.dropDown()
	end
	turtle.select(1)
end

function miner:neighbouringOres()
	-- TODO: return coords of ores around the turtle
end

function miner:inspectDown()
	-- TODO: update block info
end
