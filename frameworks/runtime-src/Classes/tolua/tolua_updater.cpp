extern "C" {
#include "tolua++.h"
}
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "updater/updater.h"
#include <string>

int tolua_downloadFile(lua_State *L)
{
    int argc = lua_gettop(L);
    bool ok = true;
    if (argc == 2) {
        std::string s1, s2;
        ok &= luaval_to_std_string(L, 1, &s1);
        ok &= luaval_to_std_string(L, 2, &s2);
        if (!ok) return 0;
        updater::downloadFile(s1, s2);
    } else {
        CCLOG("tolua_downloadFile: invalid parameters (got %d, expecting 2)", argc);
    }
    return 1;
}

int tolua_uploadFile(lua_State *L)
{
    int argc = lua_gettop(L);
    bool ok = true;
    if (argc == 5) {
        std::string s1, s2, s3, s4, s5;
        ok &= luaval_to_std_string(L, 1, &s1);
        ok &= luaval_to_std_string(L, 2, &s2);
        ok &= luaval_to_std_string(L, 3, &s3);
        ok &= luaval_to_std_string(L, 4, &s4);
        ok &= luaval_to_std_string(L, 5, &s5);
        if (!ok) return 0;
        updater::uploadFile(s1, s2, s3, s4, s5);
    } else {
        CCLOG("tolua_uploadFile: invalid parameters (got %d, expecting 5)", argc);
    }
    return 1;
}

TOLUA_API int tolua_updater_open(lua_State *L)
{
    tolua_open(L);
    tolua_module(L, NULL, 0);
    tolua_beginmodule(L, NULL);
        tolua_function(L, "downloadFile", tolua_downloadFile);
        tolua_function(L, "uploadFile", tolua_uploadFile);
    tolua_endmodule(L);
    return 1;
}
