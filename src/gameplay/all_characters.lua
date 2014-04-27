-- use require 'all_characters' to use all the characters in the game

-- the table 'SUCROSE' contains all the 'sweet' characters
SUCROSE = SUCROSE or {}

require 'src/gameplay/sucrose/chocolate'
require 'src/gameplay/sucrose/cane'

SUCROSE.create = function(name, isGoingLeft)
    isGoingLeft = isGoingLeft or false
    local ret = SUCROSE[name]:create(isGoingLeft)
    ret.UNIT.isGoingLeft = isGoingLeft
    ret.UNIT.position = function(self) return ret:getPositionX() end
    return ret
end

-- the table 'PROPS' contains all the properties
-- in order to not conflict with properties of SUCROSE, we call this 'PROPS'.
PROPS = PROPS or {}

require 'src/gameplay/props/torch'

PROPS.create = function(name)
    local ret = PROPS[name]:create()
    ret.UNIT.position = function(self) return ret:getPositionX() end
    ret.destroy = PROPS[name].destroy
    return ret
end
