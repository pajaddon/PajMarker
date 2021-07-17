
-- orderedPairs from https://wow.gamepedia.com/Orderedpairs
local function orderednext(t, n)
    local key = t[t.__next]
    if not key then return end
    t.__next = t.__next + 1
    return key, t.__source[key]
end

function orderedpairs(t, f)
    local keys, kn = {__source = t, __next = 1}, 1
    for k in pairs(t) do
        keys[kn], kn = k, kn + 1
    end
    table.sort(keys, f)
    return orderednext, keys
end

function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
