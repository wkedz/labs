-- Tables
--

local x = 1
local a = {} -- empty table
local b = { k = x, k1 = 2, k2 = 3} -- k, k1 is string
local c = { [x] = b, [1] = 1, [b] = x}


a[1] = 1
a["f"] = "f"
a[x] = 1

print(x)
print(a)
print(b)
print(c)

print(a.f) -- you can only refer this way to string key

-- this is an array - indices starts from index 1
local table2 = {"pizza", "apple", "potato"}

-- use table module to operate on arrays
table.insert(table2, "banana")
table.sort(table2)

-- ipairs 
for k,v in ipairs(table2) do
    print(k,v)
end

--pairs
local dict = { k1 = "k1", k2 = "k2", k3 = 3 }
for k,v in pairs(dict) do
    print(k,v)
end



