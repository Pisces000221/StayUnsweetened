extern "C" {
#include "tolua++.h"
}
#include "tolua_fix.h"
#include "LuaBasicConversions.h"

#include "widgets/MInfBackground.h"
using namespace M;

int tolua_MInfBackground_create(lua_State *L)
{
    int argc = 0;
    bool ok = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertable(L, 1, "MInfBackground", 0, &tolua_err))
        goto err_handle;
#endif

    argc = lua_gettop(L) - 1;
    if (argc == 1) {
        std::string filename;
        ok &= luaval_to_std_string(L, 2, &filename);
        if (!ok) return 0;
        M::InfBackground* ret = M::InfBackground::create(filename);
        object_to_luaval <M::InfBackground>
            (L, "MInfBackground", (M::InfBackground *)ret);
        return 1;
    } else if (argc == 0) {
        M::InfBackground* ret = M::InfBackground::create();
        object_to_luaval <M::InfBackground>
            (L, "MInfBackground", (M::InfBackground *)ret);
        return 1;
    }
    CCLOG("MInfBackground create: got %d argument%s, expecting 0 or 1.\n",
        argc, argc == 1 ? "" : "s");
    return 0;

#if COCOS2D_DEBUG >= 1
err_handle:
    tolua_error(L,"#ferror in function 'tolua_MInfBackground_create'.",&tolua_err);
    return 0;
#endif
}

int tolua_MInfBackground_createWithSpriteFrame(lua_State *L)
{
    std::string framename;
    if (!luaval_to_std_string(L, 2, &framename)) return 0;
    M::InfBackground *obj = M::InfBackground::createWithSpriteFrame(framename);
    tolua_pushusertype(L, obj, "MInfBackground");
    return 1;
}

TOLUA_API int tolua_MInfBackground_open(lua_State *L)
{
    tolua_open(L);
    tolua_module(L, NULL, 0);
    tolua_beginmodule(L, NULL);
        tolua_usertype(L, "MInfBackground");
        tolua_cclass(L, "MInfBackground", "MInfBackground", "cc.Layer", NULL);
        tolua_beginmodule(L, "MInfBackground");
            tolua_function(L, "create", tolua_MInfBackground_create);
            tolua_function(L, "createWithSpriteFrame", tolua_MInfBackground_createWithSpriteFrame);
        tolua_endmodule(L);
    tolua_endmodule(L);
    return 1;
}
