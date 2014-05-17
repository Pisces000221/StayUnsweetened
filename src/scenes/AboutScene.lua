require 'Cocos2d'
require 'src/global'
require 'src/widgets/SimpleMenuItemSprite'

AboutScene = {}
AboutScene.scrollHeight = 1200

function AboutScene:create()
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()

    local backButton = SimpleMenuItemSprite:create('restart',
        function() cc.Director:getInstance():popScene() end)
    backButton:setAnchorPoint(cc.p(0, 1))
    backButton:setPosition(cc.p(0, size.height))
    local backSideLen = globalImageWidth('restart')
    local menu = cc.Menu:create(backButton)
    menu:setPosition(cc.p(0, 0))
    scene:addChild(menu, 30)

    local big = function(label, i) label:getLetter(i):setScale(1.3) end
    local small = function(label, i) label:getLetter(i):setScale(.8) end

    local titleLabel = globalLabel('ABOUT STAYUNSWEETENED', 68)
    titleLabel:setAnchorPoint(cc.p(0, 1))
    titleLabel:setPosition(cc.p(backSideLen, size.height))
    --big(7); big(8); big(9);
    --for i = 11, 20 do big(i) end
    big(titleLabel, 6); big(titleLabel, 10);
    scene:addChild(titleLabel, 30)

    local scroll = MScrollView:create()
    scroll:setContentSize(cc.size(size.width, AboutScene.scrollHeight + backSideLen))
    scroll:setPosition(cc.p(0, -(AboutScene.scrollHeight + backSideLen - size.height)))
    scene:addChild(scroll)
    local cover = puritySprite(size.width, backSideLen, cc.c3b(0, 0, 0))
    cover:setAnchorPoint(cc.p(0, 1))
    cover:setPosition(cc.p(0, size.height))
    scene:addChild(cover, 10)

    local poweredAc = globalLabel('Powered by', 40)
    poweredAc:setAnchorPoint(cc.p(0, 1))
    poweredAc:setPosition(cc.p(0, AboutScene.scrollHeight))
    scroll:addChild(poweredAc)
    local fontName = 'Signika Font'
    local fontAc = globalLabel(fontName, 84, true)
    for i = 0, string.len(fontName) - 1 do small(fontAc, i) end
    fontAc:setAnchorPoint(cc.p(0, 1))
    fontAc:setPosition(cc.p(0, AboutScene.scrollHeight - 40))
    fontAc:setColor(cc.c3b(192, 192, 192))
    scroll:addChild(fontAc)

    local engineName = 'Cocos2d-x'
    local engineAc = globalLabel(engineName, 76)
    engineAc:setAnchorPoint(cc.p(1, 1))
    engineAc:setPosition(cc.p(size.width, AboutScene.scrollHeight - 130))
    engineAc:setColor(cc.c3b(128, 192, 255))
    scroll:addChild(engineAc)

    local dragDown = globalLabel('====== Drag down for more... ======', 56)
    dragDown:setAnchorPoint(cc.p(0.5, 0))
    dragDown:setPosition(cc.p(
        size.width / 2, AboutScene.scrollHeight - size.height + 112))
    dragDown:setColor(cc.c3b(128, 128, 128))
    scroll:addChild(dragDown)

    return scene
end
