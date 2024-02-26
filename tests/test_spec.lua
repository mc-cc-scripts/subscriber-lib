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

local subscriber = require("../subscriber")

describe("Subscribe", function()
    it("Table behaves normal", function()
        local t = { [1] = "test", [2] = "test2" }
        assert.are.equal("test", t[1])
        local sub = subscriber(t)
        t[3] = "test3"

        -- old table should still have the same values
        assert.are.equal("test", t[1])
        assert.are.equal("test2", t[2])
        assert.are.equal("test3", t[3])

        -- the subscriber should not have the values of the table
        assert.are.equal(nil, sub[1])
        assert.are.equal(nil, sub[2])
        assert.are.equal(nil, sub[3])
    end)

    it("Delete should trigger", function()
        local t = { [1] = "test", [2] = "test2" }
        local sub = subscriber(t)
        sub.subscribe(function(event, data)
            assert.are.equal("Delete", event)
            assert.are.equal(1, data[1])
            assert.are.equal(nil, data[2])
            assert.are.equal("test", data[3])
        end)
        t[1] = nil
        assert.are.equal(nil, t[1])
        assert.are.equal("test2", t[2])
    end)

    it("Modify should trigger", function()
        local t = { [1] = "test", [2] = "test2" }
        local sub = subscriber(t)
        sub.subscribe(function(event, data)
            assert.are.equal("Modify", event)
            assert.are.equal("test3", data[2])
            assert.is_true("test" == data[3])
        end)
        t[1] = "test3"
        assert.are.equal("test3", t[1])
        assert.are.equal("test2", t[2])
    end)
    it("Insert should trigger", function()
        local t = {}
        local sub = subscriber(t)
        sub.subscribe(function(event, data)
            assert.are.equal("Insert", event)
            assert.True(("test" == data[2]) or ("test2" == data[2]))
        end)
        t[1] = "test"
        assert.are.equal("test", t[1])
        t[2] = "test2"
        assert.are.equal("test2", t[2])
    end)
    it("Unsubscribe should work", function()
        local t = { [1] = "test", [2] = "test2" }
        local sub = subscriber(t)
        local id = sub.subscribe(function(event, data)
            assert.are.equal("Modify", event)
            assert.are.equal("new Test", data[2])
        end)
        t[1] = "new Test"
        assert.are.equal("new Test", t[1])
        sub.unsubscribe(id)
        t[2] = "new Test 2"
        assert.are.equal("new Test 2", t[2])
    end)
end)
