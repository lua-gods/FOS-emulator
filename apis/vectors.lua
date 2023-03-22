-- variables
local vectors = {}
local vector_types = {}

-- create vector function
function vectors.vec(a, b, c, d)
    if d then
        return vector_types[4](a, b, c, d)
    elseif c then
        return vector_types[3](a, b, c)
    elseif b then
        return vector_types[2](a, b)
    else
        error("Invalid arguments to vec(), needs at least 2 numbers!", 2)
    end
end

-- load vectors
local function make_vec_n(n)
    local file_data = love.filesystem.read("apis/vector_preset.lua")
    local lines = {}
    -- convert to table
    for text in string.gmatch(file_data, "[^\n]+") do
        table.insert(lines, (text:gsub("\n", "")))
    end

    -- modify
    local task = 0
    local task_data = nil
    for i, text in ipairs(lines) do
        -- do task
        if task == 1 then
            lines[i] = text:gsub("_N", n)
        elseif task == 2 then
            local str = ""
            local selected_text = text:match(";([^;]+);")
            for i2 = 1, n do
                str = str.." "..selected_text:gsub("_N", i2)
            end
            lines[i] = str
        elseif task == 3 then
            local list = {}
            local selected_text = text:match(";([^;]+);")
            for i2 = 1, n do
                table.insert(list, (selected_text:gsub("_N", i2)))
            end
            lines[i] = task_data[1]:gsub("VALUE", table.concat(list, task_data[2]))
        end
        -- reset task
        task_data = nil
        task = 0
        -- find task
        if text:match("--setN") then
            task = 1
        elseif text:match("--repeatN") then
            task = 2
            local first, second = text:match(';([^;]+);([^;]+);')
            if first and second then
                task = 3
                task_data = {first, second}
            end
        end
    end

    -- load
    local func, err = loadstring("return function(create_vector) "..table.concat(lines, "\n").." end")
    if func then
        local vec_creator = func()(vectors.vec)
        vector_types[n] = vec_creator
        vectors["vec"..n] = vec_creator
    else
        error("error when generating vector\n"..(err or func))
        -- debug save
        -- love.filesystem.write("Vector"..n..".lua", table.concat(lines, "\n"))
    end
end

function vectors.rgbToHSV(r, g, b)
    if not g then
        r, g, b = r[1], r[2], r[3]
    end
	local M, m = math.max(r, g, b), math.min(r, g, b)
	local C = M - m
	local K = 1.0/(6.0 * C)
	local h = 0.0
	if C ~= 0.0 then
		if M == r then     h = ((g - b) * K) % 1.0
		elseif M == g then h = (b - r) * K + 1.0/3.0
		else               h = (r - g) * K + 2.0/3.0
		end
	end
	return vectors.vec(h, M == 0.0 and 0.0 or C / M, M)
end

function vectors.hsvToRGB(h, s, v)
    if not s then
        h, s, v = h[1], h[2], h[3]
    end
    if s <= 0 then return v,v,v end
    h = h*6
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return vectors.vec(r+m, g+m, b+m)
end

-- generate vectors
make_vec_n(2)
make_vec_n(3)
make_vec_n(4)


return vectors