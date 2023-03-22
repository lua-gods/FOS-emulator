local function create_avatar_api(env, path, system)
    local avatar = {}
    local avatar_json = love.filesystem.read(path.."avatar.json")
    -- get authors
    local authors_raw = avatar_json:match('"authors":%[([^%]]+)%]')
    local authors_tbl = {}
    for text in authors_raw:gmatch('"([^"]+)"') do
        table.insert(authors_tbl, text)
    end
    local authors = table.concat(authors_tbl, "\n")

    function avatar:getAuthors()
        return authors
    end

    return avatar
end

return create_avatar_api