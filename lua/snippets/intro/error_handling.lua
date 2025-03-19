local calc = require("calc")
-- Error handling
--
--calc.error(true) -- this fill crash program with callstack

--if pcall(calc.error, false) then
--    print("success")
--else
--    print("failure")
--end

function ErrorHandler (err)
    print("Handling error " .. err)
end

local status= xpcall(calc.error, ErrorHandler, true)
print(status)
