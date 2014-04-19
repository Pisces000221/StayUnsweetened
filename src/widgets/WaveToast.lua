require 'Cocos2d'
require 'src/global'

WaveToast = {}
WaveToast.allShowDelay = 0.5
-- other choices: (45, 60), (54, 72)
WaveToast.textFontSize = 60
WaveToast.numberFontSize = 80
WaveToast.xPadding = 15
WaveToast.yPosRate = 0.16
WaveToast.fadeInDur = 0.5
WaveToast.fadeOutDur = 0.2
WaveToast.numberShowDelay = 1
WaveToast.numberShowTime = 2

function WaveToast.show(self, scene, number)
    local size = cc.Director:getInstance():getVisibleSize()

    local waveLabel = cc.Label:createWithTTF(
        globalTTFConfig(WaveToast.textFontSize), 'WAVE')
    waveLabel:setAnchorPoint(cc.p(1, 0.5))
    waveLabel:setPosition(cc.p(
        size.width / 2 - WaveToast.xPadding, size.height * WaveToast.yPosRate))
    waveLabel:setOpacity(0)
    scene:addChild(waveLabel)

    local numberLabel = cc.Label:createWithTTF(
        globalTTFConfig(WaveToast.numberFontSize), tostring(number))
    numberLabel:setAnchorPoint(cc.p(0, 0.5))
    numberLabel:setPosition(cc.p(
        size.width / 2 + WaveToast.xPadding, size.height * WaveToast.yPosRate))
    numberLabel:setOpacity(0)
    scene:addChild(numberLabel)
    
    waveLabel:runAction(cc.Sequence:create(
        cc.DelayTime:create(WaveToast.allShowDelay),
        cc.FadeIn:create(WaveToast.fadeInDur),
        cc.DelayTime:create(
            WaveToast.numberShowDelay + WaveToast.fadeInDur + WaveToast.numberShowTime),
        cc.FadeOut:create(WaveToast.fadeOutDur)
    ))
    numberLabel:runAction(cc.Sequence:create(
        cc.DelayTime:create(WaveToast.allShowDelay + WaveToast.fadeInDur + WaveToast.numberShowDelay),
        cc.FadeIn:create(WaveToast.fadeInDur),
        cc.DelayTime:create(WaveToast.numberShowTime + WaveToast.fadeOutDur),
        cc.FadeOut:create(WaveToast.fadeOutDur),
        cc.CallFunc:create(function() numberLabel:removeFromParent(); waveLabel:removeFromParent() end)
    ))
end
