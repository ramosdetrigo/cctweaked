local ore_table = {
    ["c:ores"] = true,
    ["c:clusters"] = true,
    ["minecraft:amethyst_block"] = true
}


---@alias ItemAction
---| '"refuel"' # Use item for refueling the turtle
---| '"keep"' # Do nothing, keep item in inventory
---| '"drop"' # Drop the item


---@type table<string, ItemAction>
local item_action_table = {
    ["c:coal"] = "refuel",
    ["c:fences/wooden"] = "refuel",
    ["c:fence_gates/wooden"] = "refuel",
    ["minecraft:logs"] = "refuel",
    ["minecraft:planks"] = "refuel",
    ["minecraft:wooden_slabs"] = "refuel",
    ["minecraft:wooden_stairs"] = "refuel",
    ["minecraft:wooden_doors"] = "refuel",
    ["minecraft:wooden_trapdoors"] = "refuel",
    ["minecraft:wooden_pressure_plates"] = "refuel",
    ["minecraft:signs"] = "refuel",

    ["c:ingots"] = "keep",
    ["c:gems"] = "keep",
    ["c:dusts"] = "keep",
    ["c:raw_materials"] = "keep",
}


-- Actions: refuel, keep, drop
---@return ItemAction
local function get_item_action(item)
    -- if no item, do nothing (keep)
    if item == nil then return "keep" end
    if item.tags then
        for tag, _ in pairs(item.tags) do
            if item_action_table[tag] then
                return item_action_table[tag]
            end
        end
    end
    return item_action_table[item.name] or "drop"
end


-- Returns true if block is considered an ore, false otherwise
---@return boolean
local function is_block_ore(block)
    if block == nil then return false; end
    if block.tags then
        for tag, _ in pairs(block.tags) do
            if ore_table[tag] then
                return ore_table[tag]
            end
        end
    end
    return ore_table[block.name] or false
end


return {
    item_action_table = item_action_table,
    ore_table = ore_table,
    get_item_action = get_item_action,
    is_block_ore = is_block_ore,
}
