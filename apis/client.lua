local client = {}

function client:getSystemTime()
    return os.time()
end

function client:getDate()
    local tbl = os.date("*t")

    return {
        week_day = tbl.wday,
        millisecond = 0,
        hour = tbl.hour,
        second = tbl.sec,
        timezone = "",
        timezone_name = "",
        daylight_saving = tbl.isdst,
        week = nil,
        minute = tbl.min,
        year = tbl.year,
        year_day = tbl.yday,
        era = ""
    }
end

return client