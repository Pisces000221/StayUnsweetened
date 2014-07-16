require 'Cocos2d'

data_save = {}

function data_save.getHighScore()
    return cc.UserDefault:getInstance():getIntegerForKey('high_score', 0)
end

function data_save.setHighScore(hi_score)
    cc.UserDefault:getInstance():setIntegerForKey('high_score', hi_score)
    cc.UserDefault:getInstance():flush()
end
