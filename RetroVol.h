#import <UIKit/UIKit.h>
#import "libcolorpicker.h"
#import "RetroVolBar.h"
#import "Globals.h"

@interface RetroVol : NSObject {
	UIWindow *springboardWindow;
	UIView *mainView;
	UILabel *label;
	RetroVolBar *bars[15];
	NSString *category;
	NSTimer *hideTimer;
	bool ringerMuted;

	NSInteger volumeBarHeight;
	NSInteger volumeBarWidth;
	float sidePadding;

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
	-(void)updateSettings;
	-(void)orientationChanged:(NSNotification *)note;
	-(void)resetToPortrait;
	-(void)updateVolumeBarPos;
@end