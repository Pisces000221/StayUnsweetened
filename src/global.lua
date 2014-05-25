require 'Cocos2d'

RES = {
    --http://stackoverflow.com/questions/12443508/possible-to-use-an-ofl-font-in-a-gpl-project
    GLOBAL_FONT = 'res/fonts/Signika-Bold.ttf',
    GLOBAL_FONT_B = 'res/fonts/Signika-Regular.ttf',
    GLOBAL_CHN_FONT = 'res/fonts/wqy-microhei.ttc'
}

AMPERE = {
    MAPSIZE = 3200,
    EXTRAMAPSIZE = 200,
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

function globalImageHeight(frameName)
    return cc.SpriteFrameCache:getInstance()
        :getSpriteFrame(frameName):getRect().height;
end

function globalImageRect(frameName)
    return cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName):getRect()
end

function globalTTFConfig(fontSize, isBold, isCHN)
    isBold = isBold or false
    isCHN = isCHN or false
    local ttfConfig = {}
    if isCHN then ttfConfig.fontFilePath = RES.GLOBAL_CHN_FONT
    elseif isBold then ttfConfig.fontFilePath = RES.GLOBAL_FONT
    else ttfConfig.fontFilePath = RES.GLOBAL_FONT_B end
    ttfConfig.fontSize = fontSize
    ttfConfig.glyphs = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    return ttfConfig
end

function globalLabel(text, fontSize, isBold)
    return cc.Label:createWithTTF(
        globalTTFConfig(fontSize, isBold), text)
end

function globalCHNLabel(text, fontSize)
    return cc.Label:createWithTTF(
        globalTTFConfig(fontSize, false, true), text)
end

-- http://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
function table.shallow_copy(t)
  local r = {}
  for k, v in pairs(t) do r[k] = v end
  return r
end
