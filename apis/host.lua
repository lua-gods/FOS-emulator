local function create_host_api(env, path, system)
    local host = {}

    function host:getChatText()
        if system.chattext and type(env.PUBLIC_REGISTRY) == "table" then
            local prefix = rawget(env.PUBLIC_REGISTRY, "keyboard_prefix")
            if prefix then
                return tostring(prefix)..system.chattext
            end
        end
        return system.chattext
    end

    function host:setChatColor()
    end

    function host:appendChatHistory()
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