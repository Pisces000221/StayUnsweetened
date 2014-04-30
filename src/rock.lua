require 'Cocos2d'
require 'src/logging'
require 'src/global'
require 'src/scenes/MYTEST/MYTEST1'
require 'src/scenes/MYTEST/MYTEST2'
require 'src/scenes/MYTEST/MYTEST3'
require 'src/scenes/StartupScene'

local function main()
    -- avoid memory leak
    collectgarbage('collect')
    collectgarbage('setpause', 100)
    collectgarbage('setstepmul', 5000)
    math.randomseed(os.time())
    cc.FileUtils:getInstance():addSearchResolutionsOrder('src');
    cc.FileUtils:getInstance():addSearchResolutionsOrder('res');
    
    -- support debugging
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD
      or platform == cc.PLATFORM_OS_ANDROID or platform == cc.PLATFORM_OS_WINDOWS
      or platform == cc.PLATFORM_OS_MAC then
        cclog('DEBUGGING ENABLED')
    else
        cclog('UNABLE TO DEBUG UNDER THIS PLATFORM...')
    end
    
    -- load sprite frames
    cc.SpriteFrameCache:getInstance():addSpriteFrames('ss.plist')
    -- run
    local scene = MYTEST3:create()

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end
end


xpcall(main, __G__TRACKBACK__)
