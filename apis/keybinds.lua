local key_map = {
    ["down"] = "key.keyboard.down",
    ["left"] = "key.keyboard.left",
    ["up"] = "key.keyboard.up",
    ["right"] = "key.keyboard.right",
    ["return"] = "key.keyboard.enter",
    ["backspace"] = "key.keyboard.backspace",
}

local function create_keybinds_api(env, path, system)
    local keyboard_enabled = false
    local keys_disabled = false
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
                    system.call(v[action])
                end
            end
        end
    end
    
    -- update
    table.insert(system.update, function()
        local keep_keys_disabled = false
        for key, figura_key in pairs(key_map) do
            local pressed = love.keyboard.isDown(key) or system.keybinds[figura_key]
            if pressed and keys_disabled then
                keep_keys_disabled = true
                pressed = false
            end
            if keyboard_enabled then
                pressed = false
            end
            if pressed ~= was_pressed[figura_key] then
                if pressed then
                    key_action(figura_key, "press")
                else
                    key_action(figura_key, "release")
                end
                was_pressed[figura_key] = pressed
            end
        end
        keys_disabled = keep_keys_disabled
    end)


    -- text input
    table.insert(system.textinput, function(text)
        if keyboard_enabled then
            if system.chattext then
                if #text == 1 then
                    system.chattext = system.chattext..text
                end
            else
                system.chattext = ""
            end
        end
    end)

    -- key pressed
    table.insert(system.keypressed, function(key)
        if keyboard_enabled then
            if love.keyboard.isDown("lctrl") and key == "v" then
                local clipboard = love.system.getClipboardText()
                if clipboard then
                    system.chattext = system.chattext..clipboard
                end
            elseif key == "escape" then
                keys_disabled = true
                keyboard_enabled = false
                system.chattext = nil
            elseif key == "return" then
                keys_disabled = true
                keyboard_enabled = false
                local prefix
                if system.chattext and type(env.PUBLIC_REGISTRY) == "table" then
                    prefix = rawget(env.PUBLIC_REGISTRY, "keyboard_prefix")
                end
                fos_system.call(fos_system.events.CHAT_SEND_MESSAGE, tostring(prefix or "")..(system.chattext or ""))
                system.chattext = nil
            elseif key == "backspace" and system.chattext then
                system.chattext = system.chattext:sub(1, -2)
            end
        else
            if key == "t" or key == "/" then
                keyboard_enabled = true
            end
        end
    end)

    -- return
    return keybinds
end

return create_keybinds_api