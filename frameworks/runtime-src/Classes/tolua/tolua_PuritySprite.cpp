extern "C" {
#include "tolua++.h"
}
#include "LuaBasicConversions.h"
#include "tolua_fix.h"
#include "cocos2d.h"
using namespace cocos2d;

Sprite *puritySprite(int width, int height, Color3B colour)
{
    int colour_num = (colour.b << 16) + (colour.g << 8) + colour.r;
    Texture2D *texture = new Texture2D();
    // CCFontAtlas.cpp (65)
    texture->initWithData(&colour_num, 1, Texture2D::PixelFormat::RGB888, 1, 1, Size(1, 1));
    Sprite *sprite = Sprite::createWithTexture(texture);
    // A little trick: create a 1x1 sprite and scale it
    sprite->setScaleX(width);
    sprite->setScaleY(height);
    return sprite;
}

int tolua_purity_Sprite(lua_State *L)
{
    int argc = lua_gettop(L);
    bool ok = true;
    if (argc == 3) {
        double width, height;
        Color3B colour;
        ok &= luaval_to_number(L, 1, &width);
        ok &= luaval_to_number(L, 2, &height);
        ok &= luaval_to_color3b(L, 3, &colour);
        if (!ok) {
            CCLOG("puritySprite: invalid parameters");
            return 0;
        }
        Sprite *obj = puritySprite((int)width, (int)height, colour);
        if (obj) {
            toluafix_pushusertype_ccobject(L,
                (int)obj->_ID, &obj->_luaID, (void *)obj, "cc.Sprite");
        } else CCLOG("puritySprite: create sprite failed");
    } else {
        CCLOG("puritySprite: invalid parameters (got %d)", argc);
    }
    return 1;
}

TOLUA_API int tolua_PuritySprite_open(lua_State *L)
{
    tolua_open(L);
    tolua_module(L, NULL, 0);
    tolua_beginmodule(L, NULL);
        tolua_function(L, "puritySprite", tolua_purity_Sprite);
    tolua_endmodule(L);
    return 1;
}
