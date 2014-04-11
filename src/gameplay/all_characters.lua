-- use require 'all_characters' to use all the characters in the game

-- the table 'SUCROSE' contains all the 'sweet' characters
SUCROSE = SUCROSE or {}

require 'src/gameplay/characters/chocolate'

SUCROSE.create = function(name, isGoingLeft)
    isGoingLeft = isGoingLeft or false
    local ret = SUCROSE[name]:create(isGoingLeft)
    return ret
end
