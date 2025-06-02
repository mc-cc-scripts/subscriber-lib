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

local observer = require("../observer")

describe("Subscribe", function()
    it("Table behaves normal", function()
        local t = { [1] = "test", [2] = "test2" }
        assert.are.equal("test", t[1])
        local sub = observer(t)
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
        local o = observer(t)
        o.subscribe(function(event, data)
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
        local o = observer(t)
        o.subscribe(function(event, data)
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
        local o = observer(t)
        o.subscribe(function(event, data)
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
        local o = observer(t)
        local id = o.subscribe(function(event, data)
            assert.are.equal("Modify", event)
            assert.are.equal("new Test", data[2])
        end)
        t[1] = "new Test"
        assert.are.equal("new Test", t[1])
        o.unsubscribe(id)
        t[2] = "new Test 2"
        assert.are.equal("new Test 2", t[2])
    end)
    describe("Multiple subscribers", function()
        it("Multiple Subscribtions shoud work", function()
            local t = { [1] = "test", [2] = "test2" }
            local o = observer(t)
            local calls = 0
            o.subscribe(function(_, _)
                calls = calls + 1
            end)
            o.subscribe(function(event, data)
                calls = calls + 1
                assert.are.equal("Modify", event)
                assert.are.equal("new Test 2", data[2])
            end)
            t[2] = "new Test 2"
            assert.are.equal("new Test 2", t[2])
            assert.are.equal(2, calls)
        end)
        it("Unsubscribing once should work", function()
            local t = { [1] = "test", [2] = "test2" }
            local o = observer(t)
            local calls = 0
            local id = o.subscribe(function(_, _)
                calls = calls + 1
            end)
            o.subscribe(function(event, data)
                calls = calls + 1
                assert.are.equal("Modify", event)
                assert.are.equal("new Test 2", data[2])
            end)
            o.unsubscribe(id)
            t[2] = "new Test 2"
            assert.are.equal("new Test 2", t[2])
            assert.are.equal(1, calls)
        end)
    end)
    describe("Metatables", function()
        it("Metatable should be set", function()
            local t = { [1] = "test" }
            local o = observer(t)
            assert.False(o.originalMetaTable == getmetatable(t))
        end)
        it("Metatable should be reset", function()
            local t = { [1] = "test" }
            local oldCall = 0
            local metatable = {
                __newindex = function(_, key, value)
                    rawset(t, key, value)
                    if (value == "new Test 2") then
                        -- gets called internally when the metatable is reset on the subscriber
                        oldCall = oldCall + 1
                    end
                end
            }
            setmetatable(t, metatable)
            local o = observer(t)
            local newCalls = 0
            o.subscribe(function(event, data)
                assert.are.equal("Modify", event)
                assert.are.equal("new Test", data[2])
                newCalls = newCalls + 1
            end)
            t[1] = "new Test"
            assert.are.equal(1, newCalls)
            o.unsubscribeAll()
            o = nil
            t[2] = "new Test 2"
            assert.are.equal(1, oldCall)
            assert.are.equal(metatable.__newindex, getmetatable(t).__newindex)
            assert.are.equal(nil, getmetatable(t).__index)
            assert.are.equal("new Test", t[1])
            assert.are.equal("new Test 2", t[2])
        end)
    end)
    describe("Resetting", function()
        it("Should reset and then Restart", function()
            local t = { [1] = "test", [2] = "test2" }
            local o = observer(t)
            o.subscribe(function(event, data)
                assert.are.equal("Modify", event)
                assert.are.equal("new Test", data[2])
            end)
            t[1] = "new Test"
            assert.are.equal("new Test", t[1])
            local t2 = o.unsubscribeAll()
            assert.are.equal("new Test", t[1])
            o.subscribe(function(event, data)
                assert.are.equal("Modify", event)
                assert.are.equal("new Test 2", data[2])
            end)
            t[2] = "new Test 2"
            assert.are.equal("new Test 2", t[2])
            assert.are.equal("new Test", t[1])
        end)
    end)
end)
