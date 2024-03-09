#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Cephei/HBPreferences.h>
#import <Cephei/HBRespringController.h>

#define TWEAK_NAME @"RetroVol"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", [TWEAK_NAME lowercaseString]]
#define BUNDLE_NOTIFY "com.wrp1002.retrovol/ReloadPrefs"

@interface PSListController (iOS12Plus)
-(void)clearCache;
-(BOOL)containsSpecifier:(PSSpecifier *)arg1;
-(void)manageBackup:(PSSpecifier *)specifier;
@end

@interface RTVRootListController : PSListController
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@end
