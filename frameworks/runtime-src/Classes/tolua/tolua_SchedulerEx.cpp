extern "C" {
#include "tolua++.h"
}
#include "tolua_fix.h"
#include "CCScheduler.h"
#include "CCDirector.h"

int tolua_new_Scheduler(lua_State *L)
{
    cocos2d::Scheduler *obj = new cocos2d::Scheduler();
    cocos2d::Director::getInstance()->getScheduler()
        ->scheduleUpdate(obj, 1, false);
    if (obj) {
        toluafix_pushusertype_ccobject(L,
            (int)obj->_ID, &obj->_luaID, (void *)obj, "cc.Scheduler");
    }
    return 1;
}

int tolua_stop_Scheduler(lua_State *L)
{
    int argc = lua_gettop(L);
    tolua_Error err;
    if (argc == 1) {
        if (!tolua_isusertype(L, 1, "cc.Scheduler", 0, &err)) {
            CCLOG("stopScheduler: invalid parameters (usertype must be cc.Scheduler)");
            return 0;
        }
        cocos2d::Scheduler *obj =
            static_cast<cocos2d::Scheduler *>(tolua_tousertype(L, 1, nullptr));
        cocos2d::Director::getInstance()->getScheduler()->unscheduleUpdate(obj);
    } else {
        CCLOG("stopScheduler: invalid parameters (got %d, expecting 1)", argc);
    }
    return 1;
}

TOLUA_API int tolua_SchedulerEx_open(lua_State *L)
{
    tolua_open(L);
    tolua_module(L, NULL, 0);
    tolua_beginmodule(L, NULL);
        tolua_function(L, "newScheduler", tolua_new_Scheduler);
        tolua_function(L, "stopScheduler", tolua_stop_Scheduler);
    tolua_endmodule(L);
    return 1;
}
