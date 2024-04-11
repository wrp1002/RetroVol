#import <Cephei/HBPreferences.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
//#import "Debug.h"
#import "libcolorpicker.h"
#import "Tweak.h"
#import "RetroVol.h"
#import "Globals.h"

#define TWEAK_NAME @"RetroVol"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", [TWEAK_NAME lowercaseString]]

//	=========================== Preference vars ===========================

BOOL enabled;
BOOL showLabel;
BOOL showBackground;
BOOL backgroundRoundCorners;
BOOL landscapeEnabled;
CGFloat delayTime = 2.0f;
CGFloat yPos = 0;
CGFloat xPos = 0;
CGFloat scale = 1.0;
NSString *barColorString = @"#00ff00";
NSString *backgroundColorString = @"#7777777";

const NSInteger barCount = 15;
NSInteger barWidth = 18;
NSInteger barHeight = 45;
NSInteger fontSize = 32;

HBPreferences *prefs;

static RetroVol *__strong retroVol;

//	=========================== Classes / Functions ===========================


// For @available to work. needs commented out for github to compile
//int __isOSVersionAtLeast(int major, int minor, int patch) { NSOperatingSystemVersion version; version.majorVersion = major; version.minorVersion = minor; version.patchVersion = patch; return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version]; }



//	=========================== Hooks ===========================

%group allVersionHooks
	%hook SpringBoard
		//	Called when springboard is finished launching
		-(void)applicationDidFinishLaunching:(id)application {
			%orig;
			retroVol = [[RetroVol alloc] init];
		}

	%end
%end

%group ios13AndUpHooks

	%hook SBVolumeControl
		// Exists only on iOS 13+
		- (void)_presentVolumeHUDWithVolume:(float)volume {
			//[Debug Log:@"_presentVolumeHUDWithVolume()"];
			if (enabled)
				[retroVol showWithVolume:volume category:[self lastDisplayedCategory]];
			else
				%orig;
		}
	%end


	%hook SBElasticVolumeViewController
		-(void)viewWillAppear:(BOOL)arg1 {
			//[Debug Log:@"viewWillAppear()"];
			if (!enabled)
				%orig;
		}
	%end


	%hook SBRingerControl
		-(void)activateRingerHUD:(int)arg1 withInitialVolume:(float)arg2 fromSource:(unsigned long long)arg3 {
			//[Debug Log:@"activateRingerHUD()"];
			if (!enabled)
				%orig;
		}

		-(void)setRingerMuted:(BOOL)arg1 {
			//[Debug Log:@"setRingerMuted()"];
			if (enabled) {
				[retroVol setMuted:arg1];
				[retroVol setCategory:@"Ringtone"];
				[retroVol show];
			}
			%orig;
		}
	%end

%end

%group ios12AndUnderHooks

	%hook VolumeControl
		-(void)_presentVolumeHUDWithMode:(int)arg1 volume:(float)arg2 {
			if (!enabled) {
				%orig;
				return;
			}

			//[Debug Log:@"_presentVolumeHUDWithMode()"];
			//[Debug Log:[NSString stringWithFormat:@"arg1: %i  arg2:%f", arg1, arg2]];

			// [self lastDisplayedCategory] always seems to return null, so figure it out manually here
			NSString *category = (arg1 == 0 ? @"Volume" : @"Ringtone");
			[retroVol showWithVolume:arg2 category:category];
		}
	%end

	%hook SBRingerHUDController
		+(void)activate:(int)arg1 {
			//[Debug Log:@"SBRingerHUDController activate() "];
			// Not calling %orig here makes setSilent not get called
			// so just deal with the ringer popup appearing here
			%orig;

			if (enabled) {
				[retroVol setCategory:@"Ringtone"];
				[retroVol show];
			}
		}
	%end

	%hook SBRingerHUDView
		-(void)setSilent:(BOOL)arg1 {
			%orig;

			if (enabled) {
				//[Debug Log:@"setSilent"];
				[retroVol setMuted:arg1];
				[retroVol setCategory:@"Ringtone"];
				[retroVol show];
			}
		}
	%end

%end


//	=========================== Constructor stuff ===========================

static void prefsDidUpdate() {
	if (!landscapeEnabled)
		[retroVol resetToPortrait];

	[retroVol updateSettings];
}

%ctor {
	prefs = [[HBPreferences alloc] initWithIdentifier:BUNDLE];

	[prefs registerBool:&enabled default:YES forKey:@"kEnabled"];
	[prefs registerBool:&showLabel default:YES forKey:@"kShowLabel"];
	[prefs registerBool:&showBackground default:NO forKey:@"kShowBackground"];
	[prefs registerBool:&backgroundRoundCorners default:NO forKey:@"kBackgroundRoundCorners"];
	[prefs registerBool:&landscapeEnabled default:NO forKey:@"kLandscape"];

	[prefs registerFloat:&delayTime default:1.0f forKey:@"kTimeout"];
	[prefs registerFloat:&xPos default:0.0f forKey:@"kXPos"];
	[prefs registerFloat:&yPos default:0.02f forKey:@"kYPos"];
	[prefs registerFloat:&scale default:1.0f forKey:@"kScale"];

	[prefs registerObject:&barColorString default:@"#00ff00" forKey:@"kBarColor"];
	[prefs registerObject:&backgroundColorString default:@"#777777" forKey:@"kBackgroundColor"];

	[prefs registerPreferenceChangeBlock:^{
		prefsDidUpdate();
	}];

	%init(allVersionHooks);

	if (@available(iOS 13.0, *)) {
		%init(ios13AndUpHooks);
	}
	else {
		%init(ios12AndUnderHooks);
	}
}
