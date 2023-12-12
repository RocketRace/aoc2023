local f = assert(io.open("input", "r"))
local rows = {}
for line in f:lines() do
    local row = { lengths = {} }
    row.pattern = line:match("[#\\?\\.]+")
    local lengths = line:match("[0-9,]+")
    for length in lengths:gmatch("[0-9]+") do
        table.insert(row.lengths, tonumber(length))
    end
    table.insert(rows, row)
end

local cache = {}
local function try(pattern, lengths)
    local hit = cache[pattern .. #lengths]
    if hit ~= nil then
        return hit
    end

    local opts = 0
    if #lengths == 0 and not pattern:find("#") then
        opts = 1
    elseif #pattern > 0 and #lengths > 0 then
        local count = lengths[1]
        local rest = { table.unpack(lengths, 2) }
        local requirement = "^" .. ("[#%?]"):rep(count) .. "$"

        local upper_bound = pattern:find("#")
        if upper_bound == nil then
            upper_bound = #pattern
        end

        for i = 1, upper_bound do
            if pattern:sub(i, i + count - 1):match(requirement) then
                local bounds = true
                if i + count <= #pattern then
                    bounds = pattern:sub(i + count, i + count) ~= "#"
                end
                if bounds then
                    local new_pattern = pattern:sub(i + count + 1)
                    -- print(i .. " (" .. count .. ") @ " .. pattern .. " -> " .. new_pattern)
                    opts = opts + try(new_pattern, rest)
                end
            end
        end
    end

    cache[pattern .. #lengths] = opts
    return opts
end

local part1 = 0
for _, row in ipairs(rows) do
    cache = {}
    part1 = part1 + try(row.pattern, row.lengths)
end

local part2 = 0
for _, row in ipairs(rows) do
    local pattern = row.pattern:rep(5, "?")
    local lengths = {}
    for _ = 1, 5 do
        table.move(row.lengths, 1, #row.lengths, #lengths + 1, lengths)
    end
    cache = {}
    part2 = part2 + try(pattern, lengths)
end

print(part1)
print(part2)
