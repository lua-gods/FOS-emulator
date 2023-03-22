local x, y, old_x, old_y
local time = -1
local start_x, start_y
local key_overrides = {}
local swipe_time = 0
local press_time = 0

local function update(delta, system)
    for i in pairs(system.keybinds) do
        system.keybinds[i] = false
    end
    for i, v in pairs(key_overrides) do
        if v[2] < 0 then
            key_overrides[i] = nil
            system.keybinds[v[1]] = false
        else
            v[2] = v[2] - delta
            if v[3] then
                if v[2] < v[3] then
                    system.keybinds[v[1]] = true
                end
            else
                system.keybinds[v[1]] = true
            end
        end
    end

    old_x, old_y = x, y
    time = math.max(time - delta, -1)
    local mouse_down = love.mouse.isDown(1)
    if press_time > 100 then
        if not mouse_down then
            press_time = 0
        end
    elseif mouse_down and not (press_time >= 0.5 and swipe_time < 0.01) then
        x, y = love.mouse.getPosition()
        if not old_x or not old_y then
            old_x, old_y = x, y
        end
        if not start_x or not start_y then
            start_x, start_y = x, y
        end
        press_time = press_time + delta
    else
        if time > 0 and start_x and start_y then
            local offset_x, offset_y = x - start_x, y - start_y
            if swipe_time >= 0.01 then
                if math.abs(offset_x) > math.abs(offset_y) then
                    table.insert(key_overrides, {offset_x < 0 and "key.keyboard.left" or "key.keyboard.right", 0.1})
                else
                    table.insert(key_overrides, {offset_y < 0 and "key.keyboard.up" or "key.keyboard.down", 0.1})
                end
                press_time = 0
            else
                if press_time > 0.5 then
                    table.insert(key_overrides, {"key.keyboard.backspace", 0.1})
                    table.insert(key_overrides, {"key.keyboard.backspace", 0.4, 0.2})
                    press_time = 101
                else
                    table.insert(key_overrides, {"key.keyboard.enter", 0.1})
                    press_time = 101
                end
            end
            swipe_time = 0
        end
        time = -1
        old_x, old_x = nil, nil
        start_x, start_y = nil, nil
        return
    end

    local vel_x, vel_y = (x - old_x) / delta, (y - old_y) / delta
    local length = math.sqrt(vel_x ^ 2 + vel_y ^ 2)
    local _, _, screen_w, screen_h = love.window.getSafeArea()
    local screen_length = math.sqrt(screen_w ^ 2 + screen_h ^ 2) * 0.5

    swipe_time = swipe_time + delta * (length > screen_length and 1 or -1)
    swipe_time = math.min(math.max(swipe_time, 0), 0.2)

    time = 0.1
end

return update