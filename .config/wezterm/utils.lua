local process = require "process"

local module = {}

function module.mergeTable(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                module.mergeTable(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

function module.notify(text)
  process.execute_command("notify-send -t 100000 -u low " .. text)
end

return module
