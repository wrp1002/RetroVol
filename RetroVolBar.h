#import <UIKit/UIKit.h>

@interface RetroVolBar : UIView {
	bool active;
}
	-(id)initWithFrame:(CGRect)frame;
	-(id)init;
	-(void)activate;
	-(void)deactivate;

@end