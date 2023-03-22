local custom = {}

-- type --
function env_type(value)
    local m = debug.getmetatable(value)
    return m and m.__type or type(value)
end

-- table --
function custom.table()
    local tbl = utils.copy_table(table)

    function tbl.pack(...)
        return {...}
    end

    tbl.unpack = unpack

    function tbl.insert(insert_to, value, index, ...)
        if insert_to and value and not index then
            insert_to[#insert_to+1] = value -- trying to prevent table.insert not calling metatable
        else
            table.insert(insert_to, value, index, ...)
        end
    end

    return tbl
end

-- math --
function custom.math()
    local tbl = utils.copy_table(math)

    function tbl.clamp(x, min, max)
        return math.min(math.max(x, min), max)
    end

    function tbl.lerp(a, b, t)
        return a + (b - a) * t
    end

    return tbl
end

function custom.loadstring(env)
    return function(str)
        local loaded, load_error = loadstring(str)
        if type(loaded) == "function" then
            return setfenv(loaded, env)
        else
            return loaded or load_error
        end
    end
end

-- require --
function custom.require(env, env_path)
    local loaded_files = {}
    return function(str)
        str = tostring(str)
        local path = env_path..str:gsub("%.", "/")..".lua"
        if loaded_files[path] then
            return unpack(loaded_files[path])
        elseif love.filesystem.getInfo(path, "file") then
            local data = love.filesystem.read(path)
            local str_func = ("--[[|"..str.."|]]return function(...) ")..data.." end"
            local loaded, load_error = loadstring(str_func)
            if type(loaded) == "function" then
                setfenv(loaded, env)
                local path_tbl = {}
                for text in string.gmatch(str..".", "([^.]+)%.") do
                    table.insert(path_tbl, text)
                end

                local data = {loaded()(unpack(path_tbl))}
                loaded_files[path] = data
                return unpack(data)
            else
                error(loaded or load_error, 2)
            end
        else
            error('Tried to require nonexistent script "'..str..'"!')
        end
    end
end

-- list files --
function custom.listFiles(env, env_path)
    return function(dir)
        dir = tostring(dir or ""):gsub("%.", "/")
        local tbl = love.filesystem.getDirectoryItems(env_path..dir)
        for i, v in pairs(tbl) do
            tbl[i] = dir.."/"..v:match('^(.*)%.lua$')
        end
        return tbl
    end
end 

return custom