local function deepcopy(tbl, copyTo)
    if type(tbl) ~= "table" then return tbl end
    copyTo = copyTo or {}
    for k, v in pairs(tbl) do
        copyTo[deepcopy(k)] = deepcopy(v)
    end
    return copyTo
end
local function emptyTable(tbl)
    for k, _ in pairs(tbl) do
        tbl[k] = nil
    end
end



---@param object table The table which the subscribtion should be created for
local CreateSubscriber = function(object)
    ---@Class Subscriber
    local subscriber = {
        obj = {},
        listeners = {},
        listenerID = 1,
        originalMetaTable = getmetatable(object),
        running = true
    }

    local function init()
        assert(type(object) == "table",
            "Subscriber can only be created for tables. Got a " .. type(object) .. " instead.")
        subscriber.obj = deepcopy(object)
        subscriber.listenerID = 1
        subscriber.listeners = {}
        subscriber.originalMetaTable = deepcopy(getmetatable(object) or {})

        emptyTable(object)
        local mt
        mt = deepcopy(getmetatable(object) or {})

        mt.__newindex = function(_, key, value)
            if value == nil then
                subscriber.notify("Delete", { key, value, subscriber.obj[key] })
            elseif subscriber.obj[key] == nil then
                subscriber.notify("Insert", { key, value })
            else
                subscriber.notify("Modify", { key, value, subscriber.obj[key] })
            end
            rawset(subscriber.obj, key, value)
        end
        mt.__index = function(_, key)
            return rawget(subscriber.obj, key)
        end
        setmetatable(object, mt)
    end

    local function returnToOriginalState()
        subscriber.listeners = nil
        subscriber.running = false
        setmetatable(object, subscriber.originalMetaTable)
        deepcopy(subscriber.obj, object)
        subscriber.obj = nil
    end

    function subscriber.subscribe(listener)
        if subscriber.running == false then
            init()
        end
        subscriber.listeners[subscriber.listenerID] = listener
        subscriber.listenerID = subscriber.listenerID + 1
        return subscriber.listenerID - 1
    end

    function subscriber.notify(event, data)
        if subscriber.listeners == nil then
            return
        end
        for _, listener in pairs(subscriber.listeners) do
            listener(event, data)
        end
    end

    function subscriber.unsubscribe(ID)
        subscriber.listeners[ID] = nil
    end

    function subscriber.unsubscribeAll()
        returnToOriginalState()
    end

    init()

    return subscriber
end

return CreateSubscriber
