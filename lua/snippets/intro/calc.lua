local M = {}

M.name = "simple calc"

M.add = function(a,b)
    return a + b
end

M.sub = function (a,b)
    return a-b
end

M.error = function (force)
    print("calling error with `force` set to: ", force)
    assert(not force, "Forced error")
end

return M
