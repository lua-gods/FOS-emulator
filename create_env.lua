-- variables
local custom = require "apis.custom"

-- env
local env = {
    -- lua
    __VERSION = "Lua 5.2 - Figura",

    type = env_type,
    print = print,
    log = {_alias = "print"},
    pairs = pairs,
    ipairs = ipairs,

    require = {_need_env = true, func = custom.require},

    pcall = pcall,
    xpcall = xpcall,
    next = next, -- i did not even knew that it exists
    assert = assert,
    select = select,
    error = error,

    bit32 = utils.read_only_table(require("bit")),

    tostring = tostring,
    tonumber = tonumber,
    string = utils.read_only_table(string),
    table = {_need_env = true, func = custom.table},
    math = {_need_env = true, func = custom.math},

    getmetatable = getmetatable,
    setmetatable = setmetatable,
    rawlen = rawlen,
    rawget = rawget,
    rawset = rawset,
    rawequal = rawequal,

    loadstring = {_need_env = true, func = custom.loadstring},
    load = {_alias = "loadstring"},
    
    -- figura
    printTable = nil,
    logTable = nil,
    printJson = nil,
    logJson = nil,

    figuraMetatables = nil, -- no metatables

    listFiles = {_need_env = true, func = custom.listFiles},

    -- figura apis
    config = {_need_env = true, func = require("apis.config_api")}, -- works, jank

    sounds = utils.read_only_table(require("apis.sounds")), -- bare minimum

    textures = {_need_env = true, func = require("apis.textures")},

    keybinds = {_need_env = true, func = require("apis.keybinds")},

    player = {_need_env = true, func = require("apis.player")}, -- minimum
    user = {_alias = "player"},

    events = {_need_env = true, func = require("apis.events")},
    
    vectors = utils.read_only_table(require("apis.vectors")), -- no vectors :<
    vec = {_alias = "vectors", _index = "vec"}, 

    client = utils.read_only_table(require("apis.client")), -- minimum

    models = {_need_env = true, func = require("apis.models")}, -- minimum

    matrices = require("apis.matrices"), -- minimum

    host = {_need_env = true, func = require("apis.host")},

    avatar = {_need_env = true, func = require("apis.avatar")},

    vanilla_model = nil,

    nameplate = nil,

    particles = nil,

    action_wheel = nil, -- not even used, useless
    
    animations = nil,

    renderer = nil,

    world = nil,

    pings = nil,
}

-- env creator --
local function create_env(path)
    local system = {
        env = utils.copy_table(env),
        error = nil,
        update = {},
        keybinds = {}
    }
    system.env._G = system.env
    system.env._GS = system.env

    for i, v in pairs(system.env) do
        if type(v) == "table" then
            if rawget(v, "_need_env") == true then
                system.env[i] = v.func(system.env, path, system)
            end
        end
    end

    for i, v in pairs(system.env) do
        if type(v) == "table" then
            if rawget(v, "_alias") then
                if v._index then
                    system.env[i] = system.env[v._alias][v._index]
                else
                    system.env[i] = system.env[v._alias]
                end
            end
        end
    end

    local run_cache = {}
    function system.run(code)
        if system.error then
            return
        end

        local loaded = run_cache[code]
        if not loaded then
            loaded = loadstring(code)
            run_cache[code] = loaded
        end

        if type(loaded) == "function" then
            setfenv(loaded, system.env)
            local success, output_error = pcall(loaded)
            if not success then
                system.error = output_error or ""
                print("fos emulator error:")
                print(system.error)
            end
        else
            print("could not run: "..code)
        end
    end

    function system.call(func)
        if system.error then
            return
        end

        local success, output_error = pcall(func)
        if not success then
            system.error = output_error or ""
            print("fos emulator error:")
            print(system.error)
        end
    end

    return system
end

-- return --
return create_env