local tbl
tbl = setmetatable({}, {
    __metatable = false,
    __newindex = function() end,
    __index = function()
        return tbl
    end,
    __call = function()
        return tbl
    end
})

return tbl