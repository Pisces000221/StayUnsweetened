require 'Cocos2d'

RES = {
    GLOBAL_FONT = 'res/fonts/Ubuntu-R.ttf',
    GLOBAL_FONT_B = 'res/fonts/Ubuntu-B.ttf'
}

AMPERE = {
    MAPSIZE = 3200,
    BALLWIDTH = 194
}

function globalSprite(frameName)
    -- Go on tricking your dad, RENDERER!!
    local frame =
        cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
    return cc.Sprite:createWithTexture(frame:getTexture(), frame:getRect())
end

function globalImageWidth(frameName)
    return cc.SpriteFrameCache:getInstance()
        :getSpriteFrame(frameName):getRect().width;
end

function globalTTFConfig(fontSize, isBold)
    isBold = isBold or false
    local ttfConfig = {}
    if isBold then ttfConfig.fontFilePath = RES.GLOBAL_FONT
    else ttfConfig.fontFilePath = RES.GLOBAL_FONT_B end
    ttfConfig.fontSize = fontSize
    ttfConfig.glyphs = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    return ttfConfig
end
