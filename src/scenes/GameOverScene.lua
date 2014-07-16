require 'Cocos2d'
require 'src/global'
require 'src/data_save'
require 'src/widgets/ScoreLabel'
require 'src/scenes/Gameplay'

GameOverScene = {}
GameOverScene.backgroundTintDur = 0.5
GameOverScene.backgroundTintWhite = 96
GameOverScene.actionInterval = 0.3
GameOverScene.energyConvertSpeed = 100
GameOverScene.balloonConvertDur = 1
GameOverScene.hiscoreCatchUpDelay = 0.6
GameOverScene.hiscoreCatchUpDur = 1

GameOverScene.energyConvertRate = 160

function GameOverScene.create(self, score, energy, balloon)
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()
    local energyConvertDur = energy / GameOverScene.energyConvertSpeed
    local convertEnergyEntry, convertBalloonEntry, hiscoreCatchUpEntry = 0, 0, 0

    -- display background
    local texture = cc.RenderTexture:create(size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    texture:beginWithClear(0, 0, 0, 0)
    cc.Director:getInstance():getRunningScene():visit()
    texture:endToLua()
    local bgSprite = texture:getSprite()
    bgSprite:removeFromParent()
    bgSprite:setAnchorPoint(cc.p(0, 0))
    bgSprite:setPosition(cc.p(0, 0))
    bgSprite:setFlippedY(true)
    scene:addChild(texture:getSprite())
    bgSprite:runAction(cc.TintTo:create(
        GameOverScene.backgroundTintDur, GameOverScene.backgroundTintWhite,
        GameOverScene.backgroundTintWhite, GameOverScene.backgroundTintWhite))

    local score_t = globalLabel('Score: ', 68, true)
    score_t:setAnchorPoint(cc.p(0, 0.5))
    score_t:setPosition(cc.p(24, size.height * 0.7))
    score_t:setOpacity(0)
    score_t:runAction(cc.Sequence:create(
        cc.DelayTime:create(GameOverScene.backgroundTintDur),
        cc.FadeIn:create(GameOverScene.actionInterval)))
    scene:addChild(score_t)
    local score_s = ScoreLabel:create(84, Gameplay.scoreLabelMaxDigits)
    score_s:setNumber(score)
    score_s:setAnchorPoint(cc.p(1, 0.5))
    score_s:setPosition(cc.p(size.width - 36, size.height * 0.7))
    score_s:setVisible(false)
    score_s:runAction(cc.Sequence:create(
        cc.DelayTime:create(GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 2),
        cc.Show:create()))
    scene:addChild(score_s)

    local energy_t = globalLabel('Energy: ', 68, true)
    energy_t:setAnchorPoint(cc.p(0, 0.5))
    energy_t:setPosition(cc.p(24, size.height * 0.4))
    energy_t:setOpacity(0)
    energy_t:runAction(cc.Sequence:create(
        cc.DelayTime:create(GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 3),
        cc.FadeIn:create(GameOverScene.actionInterval),
        cc.DelayTime:create(energyConvertDur + GameOverScene.actionInterval + 0.8),
        cc.FadeOut:create(GameOverScene.actionInterval)))
    scene:addChild(energy_t)
    local energy_s = ScoreLabel:create(84, Gameplay.energyLabelMaxDigits)
    energy_s:setNumber(energy)
    energy_s:setAnchorPoint(cc.p(1, 0.5))
    energy_s:setPosition(cc.p(size.width - 36, size.height * 0.4))
    energy_s:setVisible(false)
    energy_s:runAction(cc.Sequence:create(
        cc.DelayTime:create(GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 5),
        cc.Show:create(),
        cc.DelayTime:create(energyConvertDur + GameOverScene.actionInterval + 0.8),
        cc.Hide:create()))
    scene:addChild(energy_s)

    local energy2score = function()
        local total_dt = -(GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 6)
        convertEnergyEntry = scene:getScheduler():scheduleScriptFunc(
            function(dt)
                total_dt = total_dt + dt
                if total_dt < 0 then return end
                if total_dt >= energyConvertDur then
                    total_dt = energyConvertDur
                    scene:getScheduler():unscheduleScriptEntry(convertEnergyEntry)
                    score = score + energy * GameOverScene.energyConvertRate
                    score_s:setNumber(score)
                    energy_s:setNumber(0)
                    return
                end
                score_s:setNumber(score
                    + total_dt / energyConvertDur * energy * GameOverScene.energyConvertRate)
                energy_s:setNumber((1 - total_dt / energyConvertDur) * energy)
            end, 0, false)
    end
    energy2score()

    local balloon_t = globalLabel('Balloon: ', 68, true)
    balloon_t:setAnchorPoint(cc.p(0, 0.5))
    balloon_t:setPosition(cc.p(24, size.height * 0.4))
    balloon_t:setOpacity(0)
    balloon_t:runAction(cc.Sequence:create(
        cc.DelayTime:create(energyConvertDur
          + GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 5 + 0.8),
        cc.FadeIn:create(GameOverScene.actionInterval),
        cc.DelayTime:create(GameOverScene.balloonConvertDur + 1.6),
        cc.FadeOut:create(GameOverScene.actionInterval)))
    scene:addChild(balloon_t)
    local balloon_s = globalLabel('+ ' .. balloon .. '%', 84)
    balloon_s:setAnchorPoint(cc.p(1, 0.5))
    balloon_s:setPosition(cc.p(size.width - 36, size.height * 0.4))
    balloon_s:setVisible(false)
    balloon_s:runAction(cc.Sequence:create(
        cc.DelayTime:create(energyConvertDur
          + GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 7 + 0.8),
        cc.Show:create(),
        cc.DelayTime:create(GameOverScene.balloonConvertDur + 1.6),
        cc.Hide:create()))
    scene:addChild(balloon_s)

    local balloon2score = function()
        local total_dt = -(energyConvertDur + GameOverScene.backgroundTintDur
            + GameOverScene.actionInterval * 8 + 0.8)
        convertBalloonEntry = scene:getScheduler():scheduleScriptFunc(
            function(dt)
                total_dt = total_dt + dt
                if total_dt < 0 then return end
                if total_dt >= GameOverScene.balloonConvertDur then
                    total_dt = GameOverScene.balloonConvertDur
                    scene:getScheduler():unscheduleScriptEntry(convertBalloonEntry)
                    score = score * (1 + balloon / 100)
                    cclog('score = %d', score)
                    score_s:setNumber(score)
                    balloon_s:setString('+ 0%')
                    return
                end
                score_s:setNumber(score * (1 + total_dt / GameOverScene.balloonConvertDur * balloon / 100))
                balloon_s:setString(string.format('+ %d%%',
                    (1 - total_dt / GameOverScene.balloonConvertDur) * balloon))
            end, 0, false)
    end
    balloon2score()

    -- Load high score
    local hiscore = data_save.getHighScore()
    local hiscore_t = globalLabel('Best: ', 68, true)
    hiscore_t:setAnchorPoint(cc.p(0, 0.5))
    hiscore_t:setPosition(cc.p(24, size.height * 0.4))
    hiscore_t:setOpacity(0)
    hiscore_t:runAction(cc.Sequence:create(
        cc.DelayTime:create(energyConvertDur + GameOverScene.balloonConvertDur
          + GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 9 + 1.6),
        cc.FadeIn:create(GameOverScene.actionInterval)))
    scene:addChild(hiscore_t)
    local hiscore_s = ScoreLabel:create(84, Gameplay.scoreLabelMaxDigits)
    hiscore_s:setNumber(hiscore)
    hiscore_s:setAnchorPoint(cc.p(1, 0.5))
    hiscore_s:setPosition(cc.p(size.width - 36, size.height * 0.4))
    hiscore_s:setVisible(false)
    hiscore_s:runAction(cc.Sequence:create(
        cc.DelayTime:create(energyConvertDur + GameOverScene.balloonConvertDur
          + GameOverScene.backgroundTintDur + GameOverScene.actionInterval * 11 + 1.6),
        cc.Show:create()))
    scene:addChild(hiscore_s)

    local show_hiscore = function()
        local total_dt = -(energyConvertDur + GameOverScene.balloonConvertDur + GameOverScene.hiscoreCatchUpDur
            + GameOverScene.actionInterval * 10 + 1.6 + GameOverScene.hiscoreCatchUpDelay)
        hiscoreCatchUpEntry = scene:getScheduler():scheduleScriptFunc(
            function(dt)
                total_dt = total_dt + dt
                if total_dt < 0 then return end
                if hiscore >= score then scene:getScheduler():unscheduleScriptEntry(hiscoreCatchUpEntry); return end
                if total_dt >= GameOverScene.hiscoreCatchUpDur then
                    total_dt = GameOverScene.hiscoreCatchUpDur
                    scene:getScheduler():unscheduleScriptEntry(hiscoreCatchUpEntry)
                    data_save.setHighScore(score)
                end
                hiscore_s:setNumber((score - hiscore) * total_dt / GameOverScene.hiscoreCatchUpDur + hiscore)
            end, 0, false)
    end
    show_hiscore()

    close = function()
        score_s:runAction(cc.Hide:create())
        score_t:runAction(cc.FadeOut:create(0.4))
        hiscore_s:runAction(cc.Hide:create())
        hiscore_t:runAction(cc.FadeOut:create(0.4))
        bgSprite:runAction(cc.TintTo:create(
            GameOverScene.backgroundTintDur, 255, 255, 255))
        scene:runAction(cc.Sequence:create(
            cc.DelayTime:create(GameOverScene.backgroundTintDur),
            cc.CallFunc:create(function()
                cc.Director:getInstance():popScene() end)))
        scene:getScheduler():unscheduleScriptEntry(convertEnergyEntry)
        scene:getScheduler():unscheduleScriptEntry(convertBalloonEntry)
        scene:getScheduler():unscheduleScriptEntry(hiscoreCatchUpEntry)
    end

    local close_item = cc.MenuItemLabel:create(globalLabel('Close', 55))
    close_item:registerScriptTapHandler(close)
    close_item:setPosition(cc.p(size.width / 2, size.height * 0.18))
    local menu = cc.Menu:create(close_item)
    menu:setPosition(cc.p(0, 0))
    scene:addChild(menu)

    return scene
end
