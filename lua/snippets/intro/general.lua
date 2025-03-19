-- by default all variables are global, unless declared explicity local
--
G = 1
local l = 2

print(G)
print(l)

local a,b,c,d = 1,2,3,4
local e,f,g,h = 5,6 -- assign nill to g,h

print(a,b,c,d)
print(e,f,g,h)
