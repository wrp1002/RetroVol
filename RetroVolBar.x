#import "RetroVolBar.h"

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