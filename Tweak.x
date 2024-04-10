#import <Cephei/HBPreferences.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
//#import "Debug.h"
#import "libcolorpicker.h"
#import "Tweak.h"

#define TWEAK_NAME @"RetroVol"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", [TWEAK_NAME lowercaseString]]

//	=========================== Preference vars ===========================

BOOL enabled;
BOOL showLabel;
BOOL showBackground;
BOOL backgroundRoundCorners;
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


//	=========================== Classes / Functions ===========================


// For @available to work. needs commented out for github to compile
//int __isOSVersionAtLeast(int major, int minor, int patch) { NSOperatingSystemVersion version; version.majorVersion = major; version.minorVersion = minor; version.patchVersion = patch; return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version]; }


@interface RetroVolBar : UIView {
	bool active;
}
	-(id)initWithFrame:(CGRect)frame;
	-(id)init;
	-(void)activate;
	-(void)deactivate;

@end

@implementation RetroVolBar

	-(id)initWithFrame:(CGRect)frame {
		self = [super initWithFrame:frame];
		active = false;
		self.backgroundColor = [UIColor greenColor];

		return self;
	}

	-(id)init {
		self = [super init];
		active = true;
		self.backgroundColor = [UIColor greenColor];

		return self;
	}

	-(void)activate {
		active = true;
		self.transform = CGAffineTransformIdentity;
	}

	-(void)deactivate {
		active = false;
		self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.4);
	}
@end


@interface RetroVol : NSObject {
	UIWindow *springboardWindow;
	UIView *mainView;
	UILabel *label;
	RetroVolBar *bars[15];
	NSString *category;
	NSTimer *hideTimer;
	bool ringerMuted;
	@public bool enabled;

}
	-(id)init;
	-(void)reset;
	-(void)show;
	-(void)showWithVolume:(float)volume category:(NSString *)arg1;
	-(void)resetTimer;
	-(void)setVolume:(float)volume;
	-(void)setCategory:(NSString *)newCategory;
	-(void)setMuted:(bool)muted;
	-(void)updateOrientation;
	-(void)updateSettings;
@end

@implementation RetroVol
	-(id)init {
		self = [super init];

		if(self != nil) {
			@try {
				springboardWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
				springboardWindow.windowLevel = UIWindowLevelAlert + 2;
				[springboardWindow setUserInteractionEnabled:NO];
				[springboardWindow setBackgroundColor:[UIColor clearColor]];
				if (@available(iOS 13.0, *)) {
					springboardWindow.windowScene = [UIApplication sharedApplication].keyWindow.windowScene;
				}
				else {
					springboardWindow.screen = [UIScreen mainScreen];
				}

				int height = 90;
				float sidePadding = 20.0f;
				float volumeWidth = springboardWindow.bounds.size.width - sidePadding;
				float padding = (volumeWidth) / barCount;

				mainView = [[UIView alloc] initWithFrame:CGRectMake(sidePadding/2, springboardWindow.bounds.size.height - height, volumeWidth, height)];
				[mainView setAlpha:1.0f];
				[mainView setBackgroundColor:[UIColor clearColor]];
				[springboardWindow addSubview:mainView];

				int maxLabelHeight = 40;
				label = [[UILabel alloc] initWithFrame:CGRectMake(0, maxLabelHeight / 2 - fontSize / 2 - 5, 300, maxLabelHeight)];
				[label setTextColor:[UIColor greenColor]];
				[label setBackgroundColor:[UIColor clearColor]];
				[label setFont:[UIFont fontWithName: @"Verdana-Bold" size:fontSize]];
				[label setText:@"Volume"];
				[mainView addSubview:label];
				// Arial-BoldMT
				// Helvetica-Bold
				// Kailasa-Bold
				// Verdana-Bold

				//	Add in volume bars
				for (int i = 0; i < barCount; i++) {
					bars[i] = [[RetroVolBar alloc] initWithFrame:CGRectMake(padding * i + (float)(padding)/2.0f - barWidth/2, 40, barWidth, barHeight)];
					[mainView addSubview:bars[i]];
				}

				ringerMuted = false;
				[self updateSettings];

			} @catch (NSException *e) {
				//[Debug LogException:e];
			}
		}
		return self;
	}

	-(void)show {
		@try {
			//	Show animation window
			[self updateOrientation];
			[self setCategory:category];
			[springboardWindow setHidden:NO];
			[self resetTimer];

		}
		@catch (NSException *e) {
			//[Debug LogException:e];
		}
	}

	-(void)showWithVolume:(float)volume category:(NSString *)newCategory {
		[self setVolume:volume];
		[self setCategory:newCategory];
		[self show];
	}

	-(void)hide {
		[springboardWindow setHidden:YES];
		[hideTimer invalidate];
		hideTimer = nil;
	}

	-(void)setVolume:(float)volume {
		int count = volume * barCount;

		for (int i = 0; i < barCount; i++) {
			if (i < count || (i == 0 && volume > 0))
				[bars[i] activate];
			else
				[bars[i] deactivate];
		}
	}

	-(void)setMuted:(bool)muted {
		ringerMuted = muted;
	}

	-(void)setCategory:(NSString *)newCategory {
		category = newCategory;

		NSString *newText = @"";
		if ([newCategory isEqualToString:@"Ringtone"]) {
			if (ringerMuted)
				newText = @"Ringer (Muted)";
			else
				newText = @"Ringer";
		}
		else
			newText = @"Volume";

		[label setText:newText];
	}

	-(void)resetTimer {
		[hideTimer invalidate];
		hideTimer = nil;
		hideTimer = [NSTimer scheduledTimerWithTimeInterval:delayTime target:self selector:@selector(hide) userInfo:nil repeats:NO];
	}

	-(void)updateOrientation {
		/*
		UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
		[Debug Log:[NSString stringWithFormat:@"%ld", interfaceOrientation]];


		UIWindow *firstWindow = [[[UIApplication sharedApplication] windows] firstObject];

        UIWindowScene *windowScene = firstWindow.windowScene;

        [Debug Log:[NSString stringWithFormat:@"%i", UIInterfaceOrientationIsLandscape(windowScene.interfaceOrientation)]];


/*
		switch (orientation) {
			case UIInterfaceOrientationPortraitUpsideDown:
			{
				[Debug Log:@"upsidedown"];
			} break;

			case UIInterfaceOrientationLandscapeLeft:
			{
				[Debug Log:@"left"];
			} break;

			case UIInterfaceOrientationLandscapeRight:
			{
				[Debug Log:@"right"];
			} break;

			case UIInterfaceOrientationUnknown:
			case UIInterfaceOrientationPortrait:
			{
				[Debug Log:@"portrait"];
			}break;
			default:
			{

			} break;
		}*/
	}

	-(void)reset {
		[springboardWindow setHidden:YES];
	}

	-(void)updateSettings {
		if (showLabel)
			[label setAlpha:1.0f];
		else
			[label setAlpha:0.0f];

		UIColor *color = LCPParseColorString(barColorString, @"#00ff00");
		UIColor *bgColor = LCPParseColorString(backgroundColorString, @"#777777");

		[label setTextColor:color];

		if (showBackground)
			[mainView setBackgroundColor:bgColor];
		else
			[mainView setBackgroundColor:[UIColor clearColor]];

		mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, xPos * springboardWindow.bounds.size.width, -yPos * springboardWindow.bounds.size.height);
		mainView.transform = CGAffineTransformScale(mainView.transform, scale, scale);

		if (backgroundRoundCorners)
			mainView.layer.cornerRadius = 10;
		else
			mainView.layer.cornerRadius = 0;

		for (int i = 0; i < barCount; i++)
			[bars[i] setBackgroundColor: color];
	}

@end





static RetroVol *__strong retroVol;


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

%ctor {
	prefs = [[HBPreferences alloc] initWithIdentifier:BUNDLE];

	[prefs registerBool:&enabled default:YES forKey:@"kEnabled"];
	[prefs registerBool:&showLabel default:YES forKey:@"kShowLabel"];
	[prefs registerBool:&showBackground default:NO forKey:@"kShowBackground"];
	[prefs registerBool:&backgroundRoundCorners default:NO forKey:@"kBackgroundRoundCorners"];

	[prefs registerFloat:&delayTime default:1.0f forKey:@"kTimeout"];
	[prefs registerFloat:&xPos default:0.0f forKey:@"kXPos"];
	[prefs registerFloat:&yPos default:0.02f forKey:@"kYPos"];
	[prefs registerFloat:&scale default:1.0f forKey:@"kScale"];

	[prefs registerObject:&barColorString default:@"#00ff00" forKey:@"kBarColor"];
	[prefs registerObject:&backgroundColorString default:@"#777777" forKey:@"kBackgroundColor"];

	[prefs registerPreferenceChangeBlock:^{
		[retroVol updateSettings];
	}];

	%init(allVersionHooks);

	if (@available(iOS 13.0, *)) {
		%init(ios13AndUpHooks);
	}
	else {
		%init(ios12AndUnderHooks);
	}
}
