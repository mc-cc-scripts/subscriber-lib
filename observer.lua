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
local CreateObserver = function(object)
    ---@class Observer
    local Observer = {
        obj = {},
        listeners = {},
        listenerID = 1,
        originalMetaTable = getmetatable(object),
        running = true
    }

    local function init()
        assert(type(object) == "table",
            "Observer can only be created for tables. Got a " .. type(object) .. " instead.")
        Observer.obj = deepcopy(object)
        Observer.listenerID = 1
        Observer.listeners = {}
        Observer.originalMetaTable = deepcopy(getmetatable(object) or {})

        emptyTable(object)
        local mt
        mt = deepcopy(getmetatable(object) or {})

        mt.__newindex = function(_, key, value)
            if value == nil then
                Observer.notify("Delete", { key, value, Observer.obj[key] })
            elseif Observer.obj[key] == nil then
                Observer.notify("Insert", { key, value })
            else
                Observer.notify("Modify", { key, value, Observer.obj[key] })
            end
            rawset(Observer.obj, key, value)
        end
        mt.__index = function(_, key)
            return rawget(Observer.obj, key)
        end
        setmetatable(object, mt)
    end

    local function returnToOriginalState()
        Observer.listeners = nil
        Observer.running = false
        setmetatable(object, Observer.originalMetaTable)
        deepcopy(Observer.obj, object)
        Observer.obj = nil
    end

    function Observer.subscribe(listener)
        if Observer.running == false then
            init()
        end
        Observer.listeners[Observer.listenerID] = listener
        Observer.listenerID = Observer.listenerID + 1
        return Observer.listenerID - 1
    end

    function Observer.notify(event, data)
        if Observer.listeners == nil then
            return
        end
        for _, listener in pairs(Observer.listeners) do
            listener(event, data)
        end
    end

    function Observer.unsubscribe(ID)
        Observer.listeners[ID] = nil
    end

    function Observer.unsubscribeAll()
        returnToOriginalState()
    end

    init()

    return Observer
end

return CreateObserver
