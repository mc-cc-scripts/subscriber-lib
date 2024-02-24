---@Class CreateSubscriber
local CreateSubscriber = function(object)
    local subscriber = {
        obj = object,
        listeners = {}
    }

    function subscriber.subscribe(listener)
        table.insert(subscriber.listeners, listener)
    end

    function subscriber.notify(event, data)
        for _, listener in ipairs(subscriber.listeners) do
            listener(event, data)
        end
    end

    local mt = {
        __newindex = function(tbl, key, value)
            rawset(tbl, key, value)
            if value == nil then
                subscriber.notify("Delete", { key, value })
            else
                subscriber.notify("Modify", { key, value })
            end
        end,
        -- __gc = function(tbl)
        --     subscriber.notify("Delete", { tbl })
        -- end,
        __index = function(tbl, key)
            return rawget(tbl, key)
        end
    }

    setmetatable(subscriber, mt)

    return subscriber
end

return CreateSubscriber
