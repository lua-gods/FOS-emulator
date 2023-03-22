local function update(system)
    if not system.canvas_texture then
        if system.canvas then
            system.canvas = system.canvas:release()
        end
        return
    end

    local texture_x, texture_y = system.canvas_texture.width, system.canvas_texture.height
    local x, y = -1, -1
    if system.canvas then
        x, y = system.canvas:getDimensions()
    end

    if x ~= texture_x or y ~= texture_y or not system.canvas then
        system.canvas = love.graphics.newCanvas(texture_x, texture_y)
    end
    
    if system.canvas_texture.need_update then
        love.graphics.setCanvas(system.canvas)
        system.canvas_texture.need_update = false
        for x_pos = 0, texture_x - 1 do
            for y_pos = 0, texture_y - 1 do
                local pixel = system.canvas_texture:getPixel(x_pos, y_pos)
                love.graphics.setColor(pixel[1], pixel[2], pixel[3], pixel[4])
                love.graphics.rectangle("fill", x_pos, y_pos, 1, 1)
            end
        end
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setCanvas()
    end
end

return update