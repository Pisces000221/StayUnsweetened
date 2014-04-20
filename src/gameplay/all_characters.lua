-- use require 'all_characters' to use all the characters in the game

-- the table 'SUCROSE' contains all the 'sweet' characters
SUCROSE = SUCROSE or {}

require 'src/gameplay/characters/chocolate'
require 'src/gameplay/characters/cane'

SUCROSE.create = function(name, isGoingLeft)
    isGoingLeft = isGoingLeft or false
    local ret = SUCROSE[name]:create(isGoingLeft)
    ret.UNIT.isGoingLeft = isGoingLeft
    ret.UNIT.position = function(self) return ret:getPositionX() end
    return ret
end
