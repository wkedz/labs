-- Loops
--
-- general format for var=start, limit, step do ... end
for i =1,5 do
    print(i)
end

local i = 1
while i <= 5 do
    print(i)
    i = i + 1
end

local o = 1
repeat
    print(o)
    o = o + 1
until o <= 5


--continue ...
for w = 1,5 do
    if w == 2 then
        w = 2
        goto test

    end
    ::test::
end

local t = {1,2,3,4}
for k,v in ipairs(t) do
    print(k,v)
end
