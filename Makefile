TWEAK_NAME = CacheClearer
CacheClearer_FILES = Tweak.x
CacheClearer_FRAMEWORKS = UIKit MobileCoreServices
CacheClearer_PRIVATE_FRAMEWORKS = Preferences SpringBoardServices

IPHONE_ARCHS = armv7 arm64
ADDITIONAL_CFLAGS = -std=c99
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0

TWEAK_TARGET_PROCESS = Preferences

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
