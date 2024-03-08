#THEOS_PACKAGE_SCHEME=rootless

include $(THEOS)/makefiles/common.mk

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
	ARCHS = arm64 arm64e
	TARGET = iphone:clang:latest:15.0
else
	ARCHS = armv7 armv7s arm64 arm64e
	TARGET = iphone:clang:latest:7.0
endif

SDKVERSION = 16.5

BUNDLE_NAME = RetroVolPrefs

$(BUNDLE_NAME)_FILES = RTVRootListController.m
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
$(BUNDLE_NAME)_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk
