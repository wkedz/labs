-- String

local s1 = "string1\n"
local s2 = 'string2\n'

local multi_line = [[
line1
line2
---
]]

print(s1,s2,multi_line)

-- use string module to operat on strings

print(string.upper(s1))
print(string.reverse(s1))
-- ...
--
-- string patterns
--
local b = string.gsub("hello 42", "(%d+)", "%1 3") -- hello 42 3
local c = string.gsub("heLLo", "(%u)", "") -- heo

-- 4 + 4 = 8
local d = string.gsub("2 + 2 = 4", "(%d)", function(s)
  return s * 2
end)

-- prints each word
for w in string.gmatch("good morning chaps", "%w+") do
  print(w)
end
