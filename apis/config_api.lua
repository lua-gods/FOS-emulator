-- generate string --
local function generateString(a)
    local t = type(a)
    local env_t = env_type(a)
    if t == "number" or t == "boolean" then
        return tostring(a)
    elseif t == "string" then
        return "'"..a:gsub([[\]], [[\\]]):gsub("\n", [[\n]]):gsub("'", [[\']]).."'"
    elseif env_t == "Vector2" or env_t == "Vector3" or env_t == "Vector4" then
        return "vec("..table.concat({a[1], a[2], a[3], a[4]}, ",")..")"
    elseif t == "table" then
        local str = "{"
        for i, v in pairs(a) do
            local i2 = generateString(i)
            local v2 = generateString(v)
            if i2 and v2 then
                str = str.."["..i2.."]="..v2..","
            end
        end
        return str.."}"
    end
end

-- create config api --
local function create_config(env, path, system)
    local load_env = {vec = env.vectors.vec}

    local config = {}
    local conf_name = ""


    function config:setName(name)
        conf_name = name
    end

    function config:save(name, data)
        if not love.filesystem.getInfo(conf_name) then
            love.filesystem.createDirectory(conf_name)
        end
        love.filesystem.write(conf_name.."/"..name, generateString(data) or "nil")
    end

    function config:load(name)
        local content = love.filesystem.read(conf_name.."/"..name)
        if content then
            local func = loadstring("return "..content)
            if type(func) == "function" then
                setfenv(func, load_env)
                local success, info = pcall(func)
                if success then
                    return info
                end
            end
        end
    end

    return config
end

return create_config