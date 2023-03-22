local function find_textures(start_path_len, path, tbl, textures, vec)
    for _, filename in ipairs(love.filesystem.getDirectoryItems(path)) do
        local full_path = path..filename
        if love.filesystem.getInfo(full_path, "file") then
            if filename:sub(-4, -1) == ".png" then
                local image = love.graphics.newImage(full_path)
                local canvas = love.graphics.newCanvas(image:getWidth(), image:getHeight())
                love.graphics.setCanvas(canvas)
                love.graphics.draw(image)
                love.graphics.setCanvas()
                local imageData = canvas:newImageData()
                local width, height = imageData:getDimensions()
                local texture = textures:newTexture(full_path:sub(start_path_len + 1, -5):gsub("/", "."), width, height)
                for y = 0, height - 1 do
                    for x = 0, width - 1 do
                        local r, g, b, a = imageData:getPixel(x, y)
                        texture:setPixel(x, y, vec(r, g, b, a))
                    end
                end
                table.insert(tbl, texture)
            end
        elseif love.filesystem.getInfo(full_path, "directory") then
            find_textures(start_path_len, full_path, tbl, textures, vec)
        end
    end

    return tbl
end

local function create_texture_api(env, path, system)
    -- variables --
    local vec = env.vectors.vec
    local textures = {}
    local texture_api = {}
    local texture_metatable = {
        __metatable = false,
        __index = texture_api,
    }
    local fallback_color = vec(255, 114, 183) / 255
    local textures_list
    local textures_list_name_index = {}

    -- apis --
    function textures:newTexture(name, x, y)
        local tbl = setmetatable({
            name = name,
            width = x,
            height = y,
        }, texture_metatable)
        return tbl
    end
    
    function textures:read(name, base64)
        local imageData = love.image.newImageData(love.data.decode("data", "base64", base64))
        
        local width, height = imageData:getDimensions()
        local texture = textures:newTexture(name, width, height)
        
        for y = 0, height - 1 do
            for x = 0, width - 1 do
                local r, g, b, a = imageData:getPixel(x, y)
                texture:setPixel(x, y, vec(r, g, b, a))
            end
        end
        
        return texture
    end
    
    function textures:getTextures()
        return textures_list
    end
    
    -- object --
    function texture_api:getDimensions()
        return vec(self.width, self.height)
    end
    
    function texture_api:setPixel(x, y, color)
        local i = math.floor(x) % self.width + math.floor(y) * self.width
        self[i] = color
    end
    
    function texture_api:getPixel(x, y)
        return self[math.floor(x) % self.width + math.floor(y) * self.width] or fallback_color
    end
    
    function texture_api:getName()
        return self.name
    end
    
    function texture_api:applyFunc(x, y, w, h, func)
        for pos_x = x, x + w - 1 do
            for pos_y = y, y + h - 1 do
                local c = func(self:getPixel(pos_x, pos_y), pos_x, pos_y)
                if c then
                    self:setPixel(pos_x, pos_y, c)
                end
            end
        end
    end
    
    function texture_api:fill(x, y, w, h, c)
        for pos_x = x, x + w - 1 do
            for pos_y = y, y + h - 1 do
                self:setPixel(pos_x, pos_y, c)
            end
        end
    end
    
    function texture_api:update()
        self.need_update = true
    end

    -- textures list --
    textures_list = find_textures(#path, path, {}, textures, vec)
    for i, v in pairs(textures_list) do
        textures_list_name_index[v.name] = v
    end
    setmetatable(textures, {__index = textures_list_name_index})

    -- return --
    return textures
end
    
return create_texture_api