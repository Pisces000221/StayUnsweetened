-- use require 'all_characters' to use all the characters in the game
-- force types
FORCE_HEAT = 1
FORCE_FLOOD = 2
local minOpacity = 96
local maxOpacity = 255

-- the table 'SUCROSE' contains all the 'sweet' characters
SUCROSE = SUCROSE or {}

require 'src/gameplay/sucrose/chocolate'
require 'src/gameplay/sucrose/cane'
require 'src/gameplay/sucrose/cube'
require 'src/gameplay/sucrose/jelly'
require 'src/gameplay/sucrose/fruit'
require 'src/gameplay/sucrose/candyfloss'
require 'src/gameplay/sucrose/gingerbread'

SUCROSE.create = function(name, isGoingLeft)
    isGoingLeft = isGoingLeft or false
    local ret = SUCROSE[name]:create(isGoingLeft)
    ret:setFlippedX(isGoingLeft)
    ret.UNIT.name = name
    ret.UNIT.isGoingLeft = isGoingLeft
    ret.UNIT.maxHP = SUCROSE[name].maxHP
    ret.UNIT.HP = SUCROSE[name].maxHP
    ret.UNIT.bonus = SUCROSE[name].bonus
    ret.UNIT.damage = function(self, val)
        self.HP = self.HP - val
        ret:setOpacity((maxOpacity - minOpacity) * self.HP / self.maxHP + minOpacity)
    end
    ret.UNIT.multiplier = table.shallow_copy(SUCROSE[name].multiplier)
    ret.UNIT.position = function(self) return ret:getPositionX() end
    return ret
end

-- the table 'PROPS' contains all the properties
-- in order to not conflict with properties of SUCROSE, we call this 'PROPS'.
PROPS = PROPS or {}

require 'src/gameplay/props/torch'
require 'src/gameplay/props/cloud'
require 'src/gameplay/props/lantern'
require 'src/gameplay/props/flood'

PROPS.create = function(name)
    local ret = PROPS[name]:create()
    ret.UNIT.name = name
    ret.UNIT.position = function(self) return ret:getPositionX() end
    ret.UNIT.initialForce = table.shallow_copy(PROPS[name].initialForce)
    ret.UNIT.force = table.shallow_copy(PROPS[name].initialForce)
    ret.UNIT.initialRadius = PROPS[name].initialRadius
    ret.UNIT.destroyOnFinish = PROPS[name].destroyOnFinish
    ret.UNIT.radius = PROPS[name].initialRadius
    ret.UNIT.update = PROPS[name].update
    ret.UNIT.getForceForPosition = PROPS[name].getForceForPosition
    ret.destroy = PROPS[name].destroy
    return ret
end
