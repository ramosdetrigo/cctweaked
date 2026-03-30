local miner = require "walker"
local utils = require "utils"
local vec3 = require "vec3"


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


function miner:mineTo(target)
    -- TODO: move to coordinate while mining everything in front
end

function miner:neighbouringOres()
    -- TODO: return coords of ores around the turtle
end
