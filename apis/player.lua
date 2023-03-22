return function(env)
    local vec = env.vectors.vec
    return {
        getPos = function() return vec(0, 0, 0) end,
        getItem = function() return {id = "minecraft:air"} end,
        isLoaded = function() return true end,
    }
end