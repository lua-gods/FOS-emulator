local function create_models_api(env, path, system)
    local empty = function() end
    local methods = {
        setUVMatrix = empty,
        setPrimaryTexture = function(self, t, texture)
            if type(t) == "string" and t:lower() == "custom" then
                system.canvas_texture = texture
            end
        end,
    }

    local models
    models = setmetatable({}, {
        __metatable = false,
        __newindex = empty,
        __index = function(t, i)
            return methods[i] or models
        end
    })

    return models
end

return create_models_api