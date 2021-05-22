#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Cephei/HBPreferences.h>
#import <Cephei/HBRespringController.h>
#import <spawn.h>
#import "libcolorpicker.h"

#define TWEAK_NAME @"RetroVol"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", [TWEAK_NAME lowercaseString]]

@interface PSListController (iOS12Plus)
-(void)clearCache;
-(BOOL)containsSpecifier:(PSSpecifier *)arg1;
-(void)manageBackup:(PSSpecifier *)specifier;
@end

@interface RTVRootListController : PSListController
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@end
