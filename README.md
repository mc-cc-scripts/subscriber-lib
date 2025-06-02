# Observer-lib

A library which allows to listen to changes in any table

# Example

```lua
local createObserver = require("../observer")

local t = {
    [1] = "example",
    [2] = "example 2"
}
local s = createObserver(t)

local id = s.subscribe(function(event, data)
    print(event) -- 1. "Insert" | "Modify" | "Delete"
    print(data[1]) -- 2. key of the Value that changed
    print(data[2]) -- 3. value
    print(data[3]) -- 4. old value - if available
end)

t[1] = "example 3"
-- 1. "Modify"
-- 2. 1
-- 3. "example 3"
-- 4. "example"

t[2] = nil
-- 1. "Delete"
-- 2. 2
-- 3. nil
-- 4. "example 2"

t[3] = "example 4"
-- 1. "Insert"
-- 2. 3
-- 3. "example 4"
-- 4. nil

s.unsubscribe(id) --removes the specified subscription

s.unsubscribeAll() -- removes all subscriptions and rewrites all values from the proxy back to the original table
```
