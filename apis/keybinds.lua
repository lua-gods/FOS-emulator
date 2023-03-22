local key_map = {
    ["down"] = "key.keyboard.down",
    ["left"] = "key.keyboard.left",
    ["up"] = "key.keyboard.up",
    ["right"] = "key.keyboard.right",
    ["return"] = "key.keyboard.enter",
    ["backspace"] = "key.keyboard.backspace",
}

local function create_keybinds_api(env, path, system)
    local keybinds = {}
    
    local list = {}
    
    local was_pressed = {}
    for i, v in pairs(key_map) do
        was_pressed[v] = false
    end
    
    function isPressed(self)
        return was_pressed[self.KEY]
    end
    
    function keybinds:newKeybind(name, key)
        list[#list+1] = {KEY = key, isPressed = isPressed}
        return list[#list]
    end
    
    local function key_action(key, action)
        for i, v in pairs(list) do
            if v.KEY == key then
                if v[action] then
                    v[action]()
                end
            end
        end
    end
    
    -- update
    table.insert(system.update, function()
        for key, figura_key in pairs(key_map) do
            local pressed = love.keyboard.isDown(key) or system.keybinds[figura_key]
            if pressed ~= was_pressed[figura_key] then
                if pressed then
                    key_action(figura_key, "press")
                else
                    key_action(figura_key, "release")
                end
                was_pressed[figura_key] = pressed
            end
        end
    end)

    -- return
    return keybinds
end

return create_keybinds_api