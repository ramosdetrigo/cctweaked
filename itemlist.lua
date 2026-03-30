local items = {}


local tags = {
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
local function item_action(item)
    -- if no item, do nothing (keep)
    if item == nil then return "keep" end
    if item.tags then
        for tag, _ in pairs(item.tags) do
            if tags[tag] then
                return tags[tag]
            end
        end
    end
    return items[item.name] or "drop"
end

return { items = items, tags = tags, item_action = item_action }
