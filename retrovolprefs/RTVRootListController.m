#include "RTVRootListController.h"

@implementation RTVRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	NSArray *chosenIDs = @[@"kBackgroundColor", @"kBackgroundRoundCorners"];
	self.savedSpecifiers = (self.savedSpecifiers) ?: [[NSMutableDictionary alloc] init];
	for(PSSpecifier *specifier in _specifiers) {
		if([chosenIDs containsObject:[specifier propertyForKey:@"id"]])
			[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}

	return _specifiers;
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	NSString *key = [specifier propertyForKey:@"key"];
	if([key isEqualToString:@"kShowBackground"]) {
		if([value boolValue])
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"kBackgroundRoundCorners"], self.savedSpecifiers[@"kBackgroundColor"]] afterSpecifierID:@"kShowBackground" animated:YES];
		else
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"kBackgroundRoundCorners"], self.savedSpecifiers[@"kBackgroundColor"]] animated:YES];
	}
}

-(void)reloadSpecifiers {
	[super reloadSpecifiers];

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:BUNDLE];
	if(![prefs boolForKey:@"kShowBackground"])
		[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"kBackgroundRoundCorners"], self.savedSpecifiers[@"kBackgroundColor"]] animated:NO];
}

-(void)viewWillAppear:(BOOL)animated {
	[self clearCache];
	[self reload];  
	[super viewWillAppear:animated];
	[self reloadSpecifiers];
}

-(void)showBarColorPicker {
	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:BUNDLE];
	UIColor *color = LCPParseColorString([prefs objectForKey:@"kBarColor"], @"#00ff00");
	PFColorAlert *alert = [PFColorAlert colorAlertWithStartColor:color showAlpha:YES];

	// show alert and set completion callback
	[alert displayWithCompletion:
		^void (UIColor *pickedColor) {
			NSString *hexString = [UIColor hexFromColor:pickedColor];
			hexString = [hexString stringByAppendingFormat:@":%f", pickedColor.alpha];
			NSLog(@"RetroVol: Color ipcker update!, %@", hexString);
			[prefs setObject:hexString forKey:@"kBarColor"];
			[prefs synchronize];
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.wrp1002.retrovol/ReloadPrefs"), nil, nil, true);
		}];
}

-(void)showBackgroundColorPicker {
	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:BUNDLE];
	UIColor *color = LCPParseColorString([prefs objectForKey:@"kBackgroundColor"], @"#777777");
	PFColorAlert *alert = [PFColorAlert colorAlertWithStartColor:color showAlpha:YES];

	// show alert and set completion callback
	[alert displayWithCompletion:
		^void (UIColor *pickedColor) {
			NSString *hexString = [UIColor hexFromColor:pickedColor];
			hexString = [hexString stringByAppendingFormat:@":%f", pickedColor.alpha];
			NSLog(@"RetroVol: Color ipcker update!, %@", hexString);
			[prefs setObject:hexString forKey:@"kBackgroundColor"];
			[prefs synchronize];
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.wrp1002.retrovol/ReloadPrefs"), nil, nil, true);
		}];
}


-(void)Respring {
	[HBRespringController respring];
}

-(void)OpenGithub {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://github.com/wrp1002/TVLock"];
	[application openURL:URL options:@{} completionHandler:^(BOOL success) {
		if (success) {
			NSLog(@"Opened url");
		}
	}];
}

-(void)OpenPaypal {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://paypal.me/wrp1002"];
	[application openURL:URL options:@{} completionHandler:^(BOOL success) {
		if (success) {
			NSLog(@"Opened url");
		}
	}];
}

-(void)OpenReddit {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://reddit.com/u/wes_hamster"];
	[application openURL:URL options:@{} completionHandler:^(BOOL success) {
		if (success) {
			NSLog(@"Opened url");
		}
	}];
}

-(void)OpenEmail {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"mailto:wes.hamster@gmail.com?subject=RetroVol"];
	[application openURL:URL options:@{} completionHandler:^(BOOL success) {
		if (success) {
			NSLog(@"Opened url");
		}
	}];
}

-(void)Reset {
	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:BUNDLE];
	[prefs removeAllObjects];
	[self Respring];
}

@end
