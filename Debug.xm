#import "Debug.h"

@implementation Debug
	static bool springboardReady = false;

	+(UIWindow*)GetKeyWindow {
		UIWindow        *foundWindow = nil;
		NSArray         *windows = [[UIApplication sharedApplication]windows];
		for (UIWindow   *window in windows) {
			if (window.isKeyWindow) {
				foundWindow = window;
				break;
			}
		}
		return foundWindow;
	}

	//	Shows an alert box. Used for debugging 
	+(void)ShowAlert:(NSString *)msg {
		if (!springboardReady) return;

		UIAlertController * alert = [UIAlertController
									alertControllerWithTitle:@"Alert"
									message:msg
									preferredStyle:UIAlertControllerStyleAlert];

		//Add Buttons
		UIAlertAction* dismissButton = [UIAlertAction
									actionWithTitle:@"Cool!"
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction * action) {
										//Handle dismiss button action here
										
									}];

		//Add your buttons to alert controller
		[alert addAction:dismissButton];

		[[self GetKeyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
	}

	//	Show log with tweak name as prefix for easy grep
	+(void)Log:(NSString *)msg {
		NSLog(@"%@: %@", TWEAK_NAME, msg);
	}

	//	Log exception info
	+(void)LogException:(NSException *)e {
		NSLog(@"%@: NSException caught", TWEAK_NAME);
		NSLog(@"%@: Name:%@", TWEAK_NAME, e.name);
		NSLog(@"%@: Reason:%@", TWEAK_NAME, e.reason);
	}

	+(void)SpringBoardReady {
		springboardReady = true;
	}
@end