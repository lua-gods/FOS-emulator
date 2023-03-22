love.graphics.setDefaultFilter("nearest", "nearest")

utils = require "utils"
local create_env = require "create_env"
local update_canvas = require "apis.canvas"
local touch_input = require "touch_input"

function love.load()
    fos_system = create_env("fos/")
    
    fos_system.run('require("FOS.OS")')

    fos_system.run('APP.apps["root:home"].pages.main[8] = { text = "A"}')

    screen_orientation = "unknown"
end

local tick = 0
function love.update(delta)
    -- android screen orientation
    if love.system.getOS() == "Android" then
        if fos_system.canvas then
            local x, y = fos_system.canvas:getDimensions()
            local new_orientation = y > x and "portrait" or "landscape"
            if new_orientation ~= screen_orientation then
                screen_orientation = new_orientation
                if new_orientation == "portrait" then
                    love.window.updateMode(300, 600, {fullscreen = false})
                else
                    love.window.updateMode(600, 300, {fullscreen = false})
                end
                if fos_system.canvas_texture then
                    fos_system.canvas_texture.need_update = true
                end
            end
        end
    end

    -- emulator
    tick = tick + delta * 20
    if tick >= 1 then
        tick = tick % 1
        fos_system.run('events.TICK()')
    end
    fos_system.run('events.RENDER('..tick..', "FIRST_PERSON")')

    for _, v in ipairs(fos_system.update) do
        v(delta)
    end

    -- touch input
    touch_input(delta, fos_system)
end

function love.draw()
    update_canvas(fos_system)
    if fos_system.error then
        love.graphics.clear(0.2, 0.1, 0.1, 1)
    else
        love.graphics.clear(0.1, 0.1, 0.1, 1)
    end

    if fos_system.canvas then
        local width, height = fos_system.canvas:getDimensions()

        local screen_x, screen_y, screen_w, screen_h = love.window.getSafeArea()
    
        local aspect_ratio = width / height
        
        local x, y, w, h = 0, 0, 0, 0
    
        if screen_w / screen_h > aspect_ratio then
            h = screen_h
            w = screen_h * aspect_ratio
        else
            w = screen_w
            h = screen_w / aspect_ratio
        end
    
        x, y = (screen_w - w) / 2, (screen_h - h) / 2

        love.graphics.draw(fos_system.canvas, x + screen_x, y + screen_y, 0, w / width, h / height)
    end
    if fos_system.error then
        love.graphics.print(fos_system.error)
    end
end