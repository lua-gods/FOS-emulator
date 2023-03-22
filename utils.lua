local utils = {}

local read_only_error = function() error("table is read only") end
function utils.read_only_table(tbl)
    return setmetatable({}, {
        __metatable = false,
        __index = tbl,
        __newindex = read_only_error
    })
end

function utils.copy_table(tbl)
    local copy = {}
    for i, v in pairs(tbl) do
        copy[i] = v
    end

    return copy
end

function table.pack(...)
    return {...}
end
table.unpack = unpack

return utils