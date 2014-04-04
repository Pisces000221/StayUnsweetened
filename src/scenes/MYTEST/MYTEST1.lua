require 'Cocos2d'

MYTEST1 = {}

function MYTEST1.create()
    local scene = cc.Scene:create()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    
    local scroll = MScrollView:create()
    for i = 1, 40 do
        local label = cc.LabelTTF:create("Hi. I'm #" .. i, 'res/fonts/Ubuntu-R.ttf', 24)
        label:setPosition(cc.p(100, i * 36))
        scroll:addChild(label)
    end
    scroll:setContentSize(cc.size(visibleSize.width, 41 * 36))
    scene:addChild(scroll)
    local label_num = cc.LabelTTF:create('show posY here', 'res/fonts/Ubuntu-R.ttf', 48)
    label_num:setPosition(cc.p(500, 300))
    scene:addChild(label_num)
    
    local layer2 = cc.LayerColor:create(cc.c4b(120, 120, 220, 120))
    for i = 1, 40 do
        local label = cc.LabelTTF:create("Hello from #" .. i, 'res/fonts/Ubuntu-R.ttf', 16)
        label:setPosition(cc.p(300, i * 18))
        --http://hi.baidu.com/hizxc8/item/536c758d98ead0864414cf94
        label:setColor(cc.c3b(
            math.random(0, 255), math.random(0, 255), math.random(0, 255)))
        layer2:addChild(label)
    end
    scene:addChild(layer2)
    local layer5 = cc.LayerColor:create(cc.c4b(90, 90, 90, 50))
    layer5:setContentSize(cc.size(200, 200))
    scene:addChild(layer5)
    -- Add some code for decorating
    local label3 = cc.LabelTTF:create(
        '#include <stdio.h> int main() { printf("Hello World!\\n"); getchar(); return 0; }',
        'res/fonts/Ubuntu-B.ttf', 16)
    label3:setAnchorPoint(cc.p(1, 0))
    label3:setPosition(cc.p(visibleSize.width, 400))
    scene:addChild(label3)
    local label4 = cc.LabelTTF:create(
        "program L1; begin writeln('1 + 1 = ', 1 + 1); readln; end.",
        'res/fonts/Ubuntu-R.ttf', 27)
    label4:setAnchorPoint(cc.p(1, 0))
    label4:setPosition(cc.p(visibleSize.width, 200))
    label4:setColor(cc.c3b(255, 25, 25))
    scene:addChild(label4)
    -- Repeat the background
    local bg7 = MInfBackground:create('menu1.png')
    bg7:setPositionY(200)
    scene:addChild(bg7)
    local bg8 = MInfBackground:create('menu1.png')
    bg8:setPositionY(100)
    scene:addChild(bg8)

    local quarterHeight = visibleSize.height / 4
    local halfWidth = visibleSize.width / 2
    -- PerformanceTest.lua (1614)
    local mr90sprite = cc.Sprite:create('farm.jpg')
    local sprite6 = cc.Sprite:create('land.png')
    sprite6:setAnchorPoint(cc.p(0, 0))
    scene:addChild(sprite6)
    scene:scheduleUpdateWithPriorityLua(function(dt)
        local x1, y1 = scroll:getPosition()
        local x2, y2 = mr90sprite:getPosition()
        label_num:setString(string.format('%.6f\n%.6f', y1, x2))
        layer2:setPositionY(y1 / 2 + quarterHeight)
        label3:setPositionX(y1 + visibleSize.width)
        label4:setPositionX(-y1 / 2 + halfWidth)
        layer5:setPosition(cc.p(-y1 / 3 + 345, -y1 / 4 + 200))
        sprite6:setPosition(cc.p(x2, 0))
        bg7:setPositionX(bg7:getPositionX() + dt * 600)
        bg8:setPositionX(bg8:getPositionX() - dt * 2600)
    end, 0)
    
    -- Test action: MoveRotate90
    mr90sprite:setScale(0.4)
    mr90sprite:setOpacity(80)
    scene:addChild(mr90sprite)
    cclogtable(mr90sprite:getTextureRect())
    local mr90radius = mr90sprite:getTextureRect().width / 2 * 0.4
    mr90sprite:setPosition(cc.p(300, 200))
    mr90sprite:runAction(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.Spawn:create(
            MoveRotate90:create(3, cc.p(460, 40), true),
            cc.RotateBy:create(3, 90)
        )
    ))
    
    return scene
end
