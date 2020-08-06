function split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(Table,cap)
        end
        last_end = e+1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end

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
