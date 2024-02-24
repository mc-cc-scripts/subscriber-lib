---@class are
---@field same function
---@field equal function
---@field equals function

---@class is
---@field truthy function
---@field falsy function
---@field not_true function
---@field not_false function

---@class has
---@field error function
---@field errors function

---@class assert
---@field are are
---@field is is
---@field are_not are
---@field is_not is
---@field has has
---@field has_no has
---@field True function
---@field False function
---@field has_error function
---@field is_true function
---@field equal function
assert = assert

describe("Subscribe", function()
    it("Should trigger on Add", function()
        local subscriber = require("../subscriber")
        local t = {}
        local sub = subscriber(t)
        local triggered = ""
        local event = ""
        print(type(sub))
        sub.subscribe(function(e, keyValue)
            triggered = keyValue[2]
            event = e
        end)
        assert.are.equal("", triggered);
        sub[1] = "test"
        assert.are.equal("test", triggered);
        assert.are.equal("Modify", event);
    end)

    it("Should trigger on Delete", function()
        local subscriber = require("../subscriber")
        local t = { [1] = "test" }
        local sub = subscriber(t)
        local triggered = "indeed"
        local event = ""
        sub.subscribe(function(e, keyValue)
            print("Delete", e, keyValue[2])
            triggered = keyValue[2]
            event = e
        end)
        assert.are.equal("indeed", triggered)
        sub[1] = nil
        assert.are.equal(nil, triggered);
        assert.are.equal("Delete", event);
    end)

    it("Should trigger on Modify", function()
        local subscriber = require("../subscriber")
        local t = { [1] = "test" }
        local sub = subscriber(t)
        local triggered = ""
        local event = ""
        sub.subscribe(function(e, keyValue)
            print("Modify", e, keyValue[2])
            triggered = keyValue[2]
            event = e
        end)
        assert.are.equal("", triggered)
        sub[1] = "test2"
        assert.are.equal("test2", triggered);
        assert.are.equal("Modify", event);
    end)
end)
