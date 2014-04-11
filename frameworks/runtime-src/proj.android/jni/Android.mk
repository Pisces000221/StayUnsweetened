LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := stay-unsweetened/main.cpp \
                   ../../Classes/AppDelegate.cpp \
                   ../../Classes/actions/MoveRotate90.cpp \
                   ../../Classes/widgets/MScrollView.cpp \
                   ../../Classes/kineticroll/kc_linearscroll.c \
                   ../../Classes/tolua/tolua_MoveRotate90.cpp \
                   ../../Classes/tolua/tolua_MScrollView.cpp


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes
					
LOCAL_STATIC_LIBRARIES := curl_static_prebuilt

LOCAL_WHOLE_STATIC_LIBRARIES := cocos_lua_static

include $(BUILD_SHARED_LIBRARY)

$(call import-module,scripting/lua-bindings)
