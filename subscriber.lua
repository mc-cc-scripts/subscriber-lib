local function deepcopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[deepcopy(k)] = deepcopy(v)
    end
    setmetatable(copy, getmetatable(tbl))
    return copy
end
local function resetTableKeys(tbl)
    for k, _ in pairs(tbl) do
        tbl[k] = nil
    end
end

---@param object table The table which the subscribtion should be created for
local CreateSubscriber = function(object)
    ---@Class Subscriber
    local subscriber = {
        obj = deepcopy(object),
        listeners = {},
        listenerID = 1
    }
    resetTableKeys(object)


    function subscriber.subscribe(listener)
        subscriber.listeners[subscriber.listenerID] = listener
        subscriber.listenerID = subscriber.listenerID + 1
        return subscriber.listenerID - 1
    end

    function subscriber.notify(event, data)
        for _, listener in ipairs(subscriber.listeners) do
            listener(event, data)
        end
    end

    function subscriber.unsubscribe(ID)
        subscriber.listeners[ID] = nil
    end

    local mt = {
        __newindex = function(_, key, value)
            if value == nil then
                subscriber.notify("Delete", { key, value, subscriber.obj[key] })
            elseif subscriber.obj[key] == nil then
                subscriber.notify("Insert", { key, value })
            else
                subscriber.notify("Modify", { key, value, subscriber.obj[key] })
            end
            rawset(subscriber.obj, key, value)
        end,
        __index = function(_, key)
            return rawget(subscriber.obj, key)
        end
    }

    setmetatable(object, mt)

    return subscriber
end

return CreateSubscriber
