local function create_host_api(env, path, system)
    local host = {}

    function host:getChatText()
        return nil
    end

    function host:screenshot(name)
        if type(name) ~= "string" then
            error("string expected, got "..type(name), 2)
        end
        local texture = env.textures:newTexture(name, 1, 1)
        texture:setPixel(0, 0, env.vectors.vec4(1, 0.7098, 0.8745, 1))
        return texture
    end

    return host
end

return create_host_api