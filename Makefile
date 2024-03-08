THEOS_DEVICE_IP = 10.0.0.130
GO_EASY_ON_ME = 1
#THEOS_PACKAGE_SCHEME=rootless

TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard

PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
#PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)-$(VERSION.INC_BUILD_NUMBER)$(VERSION.EXTRAVERSION)

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
	ARCHS = arm64 arm64e
	TARGET = iphone:clang:latest:15.0
else
	ARCHS = armv7 armv7s arm64 arm64e
	TARGET = iphone:clang:latest:7.0
endif

SDKVERSION = 16.5

TWEAK_NAME = RetroVol

$(TWEAK_NAME)_FILES = $(wildcard *.x)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei
$(TWEAK_NAME)_LIBRARIES = colorpicker

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += retrovolprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
