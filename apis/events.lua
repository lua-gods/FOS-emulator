local KattEventAPI = require("libraries.KattEventsAPI")

local function create_events()
    local events = KattEventAPI.eventifyTable({})

    events.TICK = KattEventAPI.newEvent()
    events.RENDER = KattEventAPI.newEvent()

    return events
end

return create_events