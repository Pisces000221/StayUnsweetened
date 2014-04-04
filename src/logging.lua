-- The logging module
-- Biggest thanks to kikito, the author of `inspect.lua'
-- Created by Pisces000221 on January 16, 2014

local inspect = require('src/libs/inspect')

-- formats and output a string to the console
function cclog(...)
    print(string.format(...))
end

-- formats and output a table
function cclogtable(t)
    print(inspect(t))
end

-- for lua engine traceback
function __G__TRACKBACK__(message)
    cclog('----------------------------------------')
    cclog(tostring(message) .. '\n')
    cclog(debug.traceback())
end

