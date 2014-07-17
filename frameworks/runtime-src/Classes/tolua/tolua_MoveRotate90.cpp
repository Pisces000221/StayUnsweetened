extern "C" {
#include "tolua++.h"
}
#include "tolua_fix.h"
#include "LuaBasicConversions.h"

#include "actions/MoveRotate90.h"
using namespace M;

int tolua_MoveRotate90_create(lua_State *L)
{
    int argc = 0;
    bool ok = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertable(L, 1, "MoveRotate90", 0, &tolua_err)) goto err_handle;
#endif

    argc = lua_gettop(L) - 1;
    if (argc == 3) {
        double duration;
        cocos2d::Point origin;
        bool isClockwise;
        ok &= luaval_to_number(L, 2, &duration);
        ok &= luaval_to_vec2(L, 3, &origin);
        ok &= luaval_to_boolean(L, 4, &isClockwise);
        if (!ok) return 0;
        M::MoveRotate90* ret = M::MoveRotate90::create(duration, origin, isClockwise);
        object_to_luaval <M::MoveRotate90>
            (L, "MoveRotate90", (M::MoveRotate90 *)ret);
        return 1;
    } else if (argc == 2) {
        CCLOG("MoveRotate90 create @arguments 2");
        double duration;
        cocos2d::Point origin;
        ok &= luaval_to_number(L, 2, &duration);
        ok &= luaval_to_vec2(L, 3, &origin);
        if (!ok) return 0;
        M::MoveRotate90* ret = M::MoveRotate90::create(duration, origin);
        object_to_luaval <M::MoveRotate90>
            (L, "MoveRotate90", (M::MoveRotate90 *)ret);
        return 1;
    }
    CCLOG("MoveRotate90 create: got %d argument%s, expecting 2 or 3.\n",
        argc, argc == 1 ? "" : "s");
    return 0;

#if COCOS2D_DEBUG >= 1
err_handle:
    tolua_error(L,"#ferror in function 'tolua_MoveRotate90_create'.",&tolua_err);
    return 0;
#endif
}

int tolua_MoveRotate90_reverse(lua_State *L)
{
    MoveRotate90 *obj = (MoveRotate90 *)tolua_tousertype(L, 1, NULL);
    if (obj) {
        auto r = obj->reverse();
        tolua_pushusertype(L, &r, "MoveRotate90");
    }
    return 1;
}

TOLUA_API int tolua_MoveRotate90_open(lua_State *L)
{
    tolua_open(L);
    tolua_module(L, NULL, 0);
    tolua_beginmodule(L, NULL);
        tolua_usertype(L, "MoveRotate90");
        tolua_cclass(L, "MoveRotate90", "MoveRotate90", "cc.ActionInterval", NULL);
        tolua_beginmodule(L, "MoveRotate90");
            tolua_function(L, "create", tolua_MoveRotate90_create);
            tolua_function(L, "reverse", tolua_MoveRotate90_reverse);
        tolua_endmodule(L);
    tolua_endmodule(L);
    return 1;
}
