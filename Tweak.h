@interface SBVolumeControl : NSObject {
	unsigned long long _mode;
	BOOL _hudHandledLastVolumeChange;
	BOOL _volumeDownButtonIsDown;
	BOOL _volumeUpButtonIsDown;
}
@property (nonatomic,readonly) NSString * lastDisplayedCategory;
- (void)_presentVolumeHUDWithVolume:(float)volume;
- (void)_presentVolumeHUDWithMode:(int)mode volume:(float)volume;
-(void)hideVolumeHUDIfVisible;
-(void)volumeHUDViewControllerRequestsDismissal:(id)arg1 ;
@end

@interface SBElasticVolumeViewController : UIViewController {
}
-(void)viewWillAppear:(BOOL)arg1 ;
@end

@interface SBRingerControl : NSObject {

	BOOL _ringerMuted;
	float _volume;
}
@property (assign,nonatomic) float volume;
-(void)setVolume:(float)arg1 ;
-(float)volume;
-(void)setRingerMuted:(BOOL)arg1 ;
-(BOOL)isRingerMuted;
-(void)nudgeUp:(BOOL)arg1 ;
-(BOOL)lastSavedRingerMutedState;
-(void)buttonReleased;
-(void)activateRingerHUDForVolumeChangeWithInitialVolume:(float)arg1 ;
-(void)setVolume:(float)arg1 forKeyPress:(BOOL)arg2 ;
-(void)activateRingerHUD:(int)arg1 withInitialVolume:(float)arg2 fromSource:(unsigned long long)arg3 ;
-(id)existingRingerHUDViewController;
-(void)hideRingerHUDIfVisible;
-(void)ringerHUDViewControllerWantsToBeDismissed:(id)arg1 ;
-(void)toggleRingerMute;
@end


@interface VolumeControl : NSObject {
	NSString* _lastDisplayedCategory;
	NSString* _lastEventCategory;
}
-(void)_presentVolumeHUDWithMode:(int)arg1 volume:(float)arg2;
-(id)lastDisplayedCategory;
-(id)onscreenVolumeHUDMatchingCurrentCategory;
@end

@interface SBRingerHUDController : NSObject
+(void)activate:(int)arg1 ;
@end

@interface SBRingerHUDView {

	BOOL _silent;
}
@property (assign,getter=isSilent,nonatomic) BOOL silent;              //@synthesize silent=_silent - In the implementation block
-(void)_updateSilentImage;
-(BOOL)isSilent;
-(void)setSilent:(BOOL)arg1 ;
-(id)init;
@end