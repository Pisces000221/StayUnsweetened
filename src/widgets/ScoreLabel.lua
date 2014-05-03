require 'Cocos2d'
require 'src/global'

ScoreLabel = {}
ScoreLabel.zeroColour = cc.c3b(96, 96, 96)
ScoreLabel.validNumColour = cc.c3b(255, 255, 255)

function ScoreLabel.setNumber(self, number)
    local s = string.format('%0' .. self.maxDigits .. 'd', math.floor(number))
    --stackoverflow.com/questions/10989788/lua-format-integer
    s = s:reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', '')
    self:setString(s)
    local zeroes, ct = string.gsub(s, '([0\,]*).+', '%1')
    zeroes = string.len(zeroes)
    for i = 0, zeroes - 1 do self:getLetter(i):setColor(ScoreLabel.zeroColour) end
    for i = zeroes, string.len(s) - 1 do self:getLetter(i):setColor(ScoreLabel.validNumColour) end
end

function ScoreLabel.create(self, fontsize, maxdigits)
    local label = cc.Label:createWithTTF({
        fontFilePath = 'res/fonts/signika.ttf', fontSize = fontsize,
        glyphs = cc.GLYPHCOLLECTION_DYNAMIC, distanceFieldEnabled = true
    }, '')
    label.setNumber = ScoreLabel.setNumber
    label.maxDigits = maxdigits
    label:setNumber(0)
    --cclog('maxdigits =')
    --cclogtable(maxdigits)
    return label
end
