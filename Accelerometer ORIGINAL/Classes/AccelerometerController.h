//
//  Created by Ray Wisman on July 31, 2010.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "AccelerometerData.h"
#import "SoundEffect.h"

@interface AccelerometerController  : UIViewController <UIAccelerometerDelegate, MFMailComposeViewControllerDelegate> {
	IBOutlet UILabel *labelX;
	IBOutlet UILabel *labelY;
	IBOutlet UILabel *labelZ;
	IBOutlet UILabel *sampleRateLabel;
	IBOutlet UILabel *endIndexLabel;
	IBOutlet UILabel *endIndexValueLabel;
	
	IBOutlet UIProgressView *progressX;
	IBOutlet UIProgressView *progressY;
	IBOutlet UIProgressView *progressZ;
	IBOutlet UISlider *sampleRateSlider;
	IBOutlet UISlider *endIndexSlider;
	IBOutlet UISwitch *calibrationSwitch;
	
	UIAccelerometer *accelerometer;	
	NSNotificationCenter *notificationCenter;
	AccelerometerData *accelerometerData;
    SoundEffect *stopSound;
    SoundEffect *startSound;
    SoundEffect *calibrateSound;
}

@property(readwrite, retain, nonatomic) AccelerometerData *accelerometerData;

@property (nonatomic, retain) IBOutlet UILabel *labelX;
@property (nonatomic, retain) IBOutlet UILabel *labelY;
@property (nonatomic, retain) IBOutlet UILabel *labelZ;
@property (nonatomic, retain) IBOutlet UILabel *sampleRateLabel;
@property (nonatomic, retain) IBOutlet UILabel *endIndexLabel;
@property (nonatomic, retain) IBOutlet UILabel *endIndexValueLabel;

@property (nonatomic, retain) IBOutlet UIProgressView *progressX;
@property (nonatomic, retain) IBOutlet UIProgressView *progressY;
@property (nonatomic, retain) IBOutlet UIProgressView *progressZ;

@property (nonatomic, retain) IBOutlet UISlider *sampleRateSlider;
@property (nonatomic, retain) IBOutlet UISlider *endIndexSlider;
@property (nonatomic, retain) IBOutlet UISwitch *calibrationSwitch;

@property (nonatomic, retain) UIAccelerometer *accelerometer;
@property (nonatomic, retain) NSNotificationCenter *notificationCenter;

-(IBAction) startStopButton: (id) sender; 
-(IBAction) sendButton: (id) sender;
-(IBAction) sampleRateSliderAction: (id) sender;
-(IBAction) endIndexSliderAction: (id) sender;
-(IBAction) calibrateSwitch: (id) sender;

@end

