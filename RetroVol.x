#import "RetroVol.h"

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

				ringerMuted = false;
				volumeBarHeight = 90;
				sidePadding = 20.0f;
				volumeBarWidth = springboardWindow.bounds.size.width - sidePadding;
				float padding = (volumeBarWidth) / barCount;
				float xPos = sidePadding / 4 + springboardWindow.bounds.size.width / 2 - volumeBarWidth / 2;

				mainView = [[UIView alloc] initWithFrame:CGRectMake(xPos, springboardWindow.bounds.size.height - volumeBarHeight, volumeBarWidth, volumeBarHeight)];
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

				[self updateSettings];

				[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
				[[NSNotificationCenter defaultCenter]
					addObserver:self selector:@selector(orientationChanged:)
					name:UIDeviceOrientationDidChangeNotification
					object:[UIDevice currentDevice]
				];

			} @catch (NSException *e) {
				//[Debug LogException:e];
			}
		}
		return self;
	}

	-(void)show {
		@try {
			//	Show animation window
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

	-(void)orientationChanged:(NSNotification *)note {
		if (!landscapeEnabled)
			return;

		UIDevice *device = note.object;
		UIDeviceOrientation orientation = device.orientation;
		CGRect screenBounds = [UIScreen mainScreen].fixedCoordinateSpace.bounds;

		switch (orientation) {
			case UIInterfaceOrientationPortrait:
				self->springboardWindow.transform = CGAffineTransformIdentity;
				self->springboardWindow.frame = CGRectMake(0, 0, CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds));
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				self->springboardWindow.transform = CGAffineTransformMakeRotation(M_PI);
				self->springboardWindow.frame = CGRectMake(0, 0, CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds));
				break;
			case UIInterfaceOrientationLandscapeLeft:
				self->springboardWindow.transform = CGAffineTransformMakeRotation(-M_PI_2);
				self->springboardWindow.frame = CGRectMake(0, 0, CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds));
				break;
			case UIInterfaceOrientationLandscapeRight:
				self->springboardWindow.transform = CGAffineTransformMakeRotation(M_PI_2);
				self->springboardWindow.frame = CGRectMake(0, 0, CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds));
				break;
			default:
				break;
		}

		[self updateVolumeBarPos];
		[self updateSettings];
	}

	-(void)resetToPortrait {
		CGRect screenBounds = [UIScreen mainScreen].fixedCoordinateSpace.bounds;

		self->springboardWindow.transform = CGAffineTransformIdentity;
		self->springboardWindow.frame = CGRectMake(0, 0, CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds));

		[self updateVolumeBarPos];
	}

	-(void)updateVolumeBarPos {
		float springBoardWindowWidth = springboardWindow.bounds.size.width;
		float xPos = sidePadding / 4 + springBoardWindowWidth / 2 - volumeBarWidth / 2;
		mainView.transform = CGAffineTransformIdentity;
		mainView.frame = CGRectMake(xPos, springboardWindow.bounds.size.height - volumeBarHeight, volumeBarWidth, volumeBarHeight);
	}

@end