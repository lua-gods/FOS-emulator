--setN
local vector_type = "Vector_N"
local methods
local metatable
local function create(...)
    local tbl = {...}
    local vector = {}
    --repeatN
    ;vector[_N] = tbl[_N] or 0;
    return setmetatable(vector, metatable)
end

methods = {
    augmented = function(self, a)
        local tbl = {self:unpack()}
        table.insert(tbl, a or 1)
        return create_vector(unpack(tbl))
    end,
    set = function(self, a, b, ...)
        if b then
            local tbl = {a, b, ...}
            --repeatN
            ;self[_N] = tbl[_N];
        else
            --repeatN
            ;self[_N] = b[_N];
        end

        return self
    end,
    add = function(self, a, b, ...)
        if b then
            local tbl = {a, b, ...}
            --repeatN
            ;self[_N] = self[_N] + tbl[_N];
        else
            --repeatN
            ;self[_N] = self[_N] + b[_N];
        end

        return self
    end,
    sub = function(self, a, b, ...)
        if b then
            local tbl = {a, b, ...}
            --repeatN
            ;self[_N] = self[_N] - tbl[_N];
        else
            --repeatN
            ;self[_N] = self[_N] - b[_N];
        end

        return self
    end,
    mul = function(self, a, b, ...)
        if b then
            local tbl = {a, b, ...}
            --repeatN
            ;self[_N] = self[_N] * tbl[_N];
        else
            --repeatN
            ;self[_N] = self[_N] * b[_N];
        end

        return self
    end,
    div = function(self, a, b, ...)
        if b then
            local tbl = {a, b, ...}
            --repeatN
            ;self[_N] = self[_N] / tbl[_N];
        else
            --repeatN
            ;self[_N] = self[_N] / b[_N];
        end

        return self
    end,
    reduce = function(self, a, b, ...)
        if b then
            local tbl = {a, b, ...}
            --repeatN
            ;self[_N] = self[_N] % tbl[_N];
        else
            --repeatN
            ;self[_N] = self[_N] % b[_N];
        end

        return self
    end,
    offset = function(self, offset)
        --repeatN
        ;self[_N] = self[_N] + offset;

        return self
    end,
    scale = function(self, offset)
        --repeatN
        ;self[_N] = self[_N] * offset;

        return self
    end,
    applyFunc = function(self, func)
        --repeatN
        ;self[_N] = func(self[_N], _N);

        return self
    end,
    ceil = function(self)
        --repeatN
        ;self[_N] = math.ceil(self[_N]);

        return self
    end,
    floor = function(self)
        --repeatN
        ;self[_N] = math.floor(self[_N]);

        return self
    end,
    toDeg = function(self)
        --repeatN
        ;self[_N] = math.deg(self[_N]);

        return self
    end,
    toRad = function(self)
        --repeatN
        ;self[_N] = math.rad(self[_N]);

        return self
    end,
    length = function(self)
        --repeatN ;return math.sqrt(VALUE);+;
        -- ;self[_N]^2;
    end,
    lengthSquared = function(self)
        --repeatN ;return VALUE;+;
        -- ;self[_N]^2;
    end,
    unpack = function(self)
        --repeatN ;return VALUE;, ;
        --;self[_N];
    end,
    copy = function(self)
        return create(self:unpack())
    end,
    normalize = function(self)
        local len = self:length()

        --repeatN
        ;self[_N] = self[_N] / len;
        
        return self
    end,
    normalized = function(self)
        local vec = self:copy()
        local len = self:length()

        --repeatN
        ;vec[_N] = vec[_N] / len;

        return vec
    end,
    clampLength = function(self, min, max)
        local value = self:length()
        value = math.min(math.max(value, min), max) / value

        --repeatN
        ;self[_N] = self[_N] * value;

        return self
    end,
    dot = function(a, b)
        --repeatN ;return VALUE; + ;
        --;a[_N] * b[_N];
    end,
    reset = function(self)
        --repeatN
        ;a[_N] = 0;
        return self
    end,
}

metatable = {
    __type = vector_type,
    __metatable = false,

    __index = function(t, i)
        if i == "x" then return t[1]
        elseif i == "y" then return t[2]
        elseif i == "z" then return t[3]
        elseif i == "w" then return t[4]
        elseif i == "r" then return t[1]
        elseif i == "g" then return t[2]
        elseif i == "b" then return t[3]
        elseif i == "a" then return t[4]
        elseif i == "_" then return 0
        elseif methods[i] then
            return methods[i]
        elseif type(i) == "string" and #i >= 2 then
            local tbl = {}
            for i2 = 1, #i do
                table.insert(tbl, t[i:sub(i2, i2)] or 0)
            end

            return create_vector(unpack(tbl))
        end
    end,
    __newindex = function(t, i, v)
        if i == "x" then t[1] = v
        elseif i == "y" then t[2] = v
        elseif i == "z" then t[3] = v
        elseif i == "w" then t[4] = v
        elseif i == "r" then t[1] = v
        elseif i == "g" then t[2] = v
        elseif i == "b" then t[3] = v
        elseif i == "a" then t[4] = v
        else rawset(t, i, v) end
    end,
    __tostring = function(t)
        return '{'..table.concat(t, ",").."}"
    end,
    __mod = function(a, b)
        if env_type(a) == vector_type then
            a = a:copy()
            if env_type(b) == vector_type then
                --repeatN
                ;a[_N] = a[_N] % b[_N];
                return a
            else
                --repeatN
                ;a[_N] = a[_N] % b;
                return a
            end
        else
            b = b:copy()
            --repeatN
            ;b[_N] = a % b[_N];
            return b
        end
    end,
    __add = function(a, b)
        if env_type(a) == vector_type then
            a = a:copy()
            if env_type(b) == vector_type then
                --repeatN
                ;a[_N] = a[_N] + b[_N];
                return a
            else
                --repeatN
                ;a[_N] = a[_N] + b;
                return a
            end
        else
            b = b:copy()
            --repeatN
            ;b[_N] = a + b[_N];
            return b
        end
    end,
    __unm = function(a)
        a = a:copy()
        --repeatN
        ;a[_N] = -a[_N];

        return a
    end,
    __eq = function(a, b)
        if env_type(b) == vector_type then
            --repeatN
            ;if a[_N] ~= b[_N] then return false end;
            return true
        else
            return false
        end
    end,
    __len = function()
        --setN
        return _N
    end,
    __mul = function(a, b)
        if env_type(a) == vector_type then
            a = a:copy()
            if env_type(b) == vector_type then
                --repeatN
                ;a[_N] = a[_N] * b[_N];
                return a
            else
                --repeatN
                ;a[_N] = a[_N] * b;
                return a
            end
        else
            b = b:copy()
            --repeatN
            ;b[_N] = a * b[_N];
            return b
        end
    end,
    __sub = function(a, b)
        if env_type(a) == vector_type then
            a = a:copy()
            if env_type(b) == vector_type then
                --repeatN
                ;a[_N] = a[_N] - b[_N];
                return a
            else
                --repeatN
                ;a[_N] = a[_N] - b;
                return a
            end
        else
            b = b:copy()
            --repeatN
            ;b[_N] = a - b[_N];
            return b
        end
    end,
    __div = function(a, b)
        if env_type(a) == vector_type then
            a = a:copy()
            if env_type(b) == vector_type then
                --repeatN
                ;a[_N] = a[_N] / b[_N];
                return a
            else
                --repeatN
                ;a[_N] = a[_N] / b;
                return a
            end
        else
            b = b:copy()
            --repeatN
            ;b[_N] = a / b[_N];
            return b
        end
    end,
    __lt = function(a, b)
        --repeatN
        ;if a[_N] >= b[_N] then return false end;
        return true
    end,
    __le = function(a, b)
        --repeatN
        ;if a[_N] > b[_N] then return false end;
        return true
    end
}

return create