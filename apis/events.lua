local KattEventAPI = require("libraries.KattEventsAPI")

local function create_events(env, path, system)
    local tbl = KattEventAPI.eventifyTable({})
    local events = {}

    events.TICK = KattEventAPI.newEvent()
    events.RENDER = KattEventAPI.newEvent()
    events.CHAT_SEND_MESSAGE = KattEventAPI.newEvent()

    system.events = events

    for i, v in pairs(events) do
        tbl[i] = v
    end

    return tbl
end

return create_events