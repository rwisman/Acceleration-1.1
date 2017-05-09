//
//  Created by Ray Wisman on July 31, 2010.
//

#import "AccelerometerController.h"

@implementation AccelerometerController

@synthesize labelX;
@synthesize labelY;
@synthesize labelZ;
@synthesize sampleRateLabel;
@synthesize endIndexLabel;
@synthesize endIndexValueLabel;
@synthesize calibrationSwitch;

@synthesize progressX;
@synthesize progressY;
@synthesize progressZ;

@synthesize sampleRateSlider;
@synthesize endIndexSlider;

@synthesize accelerometer;
@synthesize notificationCenter;

@synthesize accelerometerData;

UIButton * startStopButton;

float dataX[MAXSAMPLES], dataY[MAXSAMPLES], dataZ[MAXSAMPLES];

int n=0;
BOOL start=FALSE, calibrating=TRUE;
int calibrationN = 0;

float calibrateX, calibrateY, calibrateZ; 

- (BOOL)shouldAutorotateToInterfaceOrientation:
	(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)setupSounds {
    NSBundle *mainBundle = [NSBundle mainBundle];
	
    stopSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"stopSound" ofType:@"caf"]];
    startSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"startSound" ofType:@"caf"]];
    calibrateSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"calibrateSound" ofType:@"caf"]];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.notificationCenter = [NSNotificationCenter defaultCenter];
	
	self.accelerometerData = nil;
	
	self.title = @"Acceleration";
	[notificationCenter addObserver: self 
						   selector: @selector(updateData:) 
							   name: @"DATAREQUEST" 
							 object: nil];	
	
	sampleRateSlider.maximumValue = 100.0f;
	sampleRateSlider.minimumValue = 1.0f;
	sampleRateSlider.value = 10;
	
	[sampleRateSlider setThumbImage:[UIImage imageNamed:@"samplesPerSecond.PNG"] forState:UIControlStateNormal];
	[sampleRateSlider setThumbImage:[UIImage imageNamed:@"samplesPerSecond.PNG"] forState:UIControlStateHighlighted];
	
	[endIndexSlider setThumbImage:[UIImage imageNamed:@"clock-32x32.png"] forState:UIControlStateHighlighted];
	[endIndexSlider setThumbImage:[UIImage imageNamed:@"clock-32x32.png"] forState:UIControlStateNormal];

	// Hack for iPad only, otherwise this slider disappears
	// Use images from a slider that does appear
	[endIndexSlider setMaximumTrackImage:[sampleRateSlider currentMaximumTrackImage] forState:UIControlStateNormal];	
	[endIndexSlider setMinimumTrackImage:[sampleRateSlider currentMinimumTrackImage] forState:UIControlStateNormal];	

	endIndexSlider.maximumValue = 0.0f;
	endIndexSlider.minimumValue = 0.0f;
	endIndexSlider.value = 0.0;

	NSString *s = [[NSString alloc] initWithFormat:@"%d", (int)sampleRateSlider.value];
	sampleRateLabel.text=s;
	[s release];
	
	calibrating=YES;
	[self setupSounds];
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	self.accelerometer = [UIAccelerometer sharedAccelerometer];
	self.accelerometer.updateInterval = 1/sampleRateSlider.value;
	self.accelerometer.delegate = self;
}

-(IBAction) calibrateSwitch: (id) sender {
	UISwitch *switched = (UISwitch *) sender;
	calibrating = switched.on;
	if(!calibrating) {
		calibrateX=0.0;
		calibrateY=0.0;
		calibrateZ=0.0;
		calibrationN = 0;
	}
}

-(IBAction) sampleRateSliderAction: (id) sender {
	NSString *s = [[NSString alloc] initWithFormat:@"%d", (int)sampleRateSlider.value];
	self.accelerometer.updateInterval = 1/sampleRateSlider.value;
	sampleRateLabel.text=s;
	[s release];
}

-(IBAction) endIndexSliderAction: (id) sender {
	if( self.accelerometerData == nil) return;
	
	[[UIAccelerometer sharedAccelerometer] setDelegate: nil];

	NSString *s = [[NSString alloc] initWithFormat:@"%3.2f", (int)endIndexSlider.value*self.accelerometer.updateInterval];
	endIndexLabel.text=s;
	[s release];
	
	int index = (int)endIndexSlider.value;
	
/*	Uncomment to enable slider modification of the end time displayed in graph. Not really necessary since user can do directly on graph.
 
	self.accelerometerData.endIndex = index;		
	[notificationCenter postNotificationName: @"DATACHANGE" object: accelerometerData];
*/	
	float x = dataX[index];
	float y = dataY[index];
	float z = dataZ[index];
	
	labelX.text = [NSString stringWithFormat:@"%@%3.2f", @"X: ", x];
	labelY.text = [NSString stringWithFormat:@"%@%3.2f", @"Y: ", y];
	labelZ.text = [NSString stringWithFormat:@"%@%3.2f", @"Z: ", z];
	
	self.progressX.progress = (4+x)/8;
	self.progressY.progress = (4+y)/8;
	self.progressZ.progress = (4+z)/8;	
	
}

-(IBAction) startStopButton: (id) sender {
	startStopButton = (UIButton *) sender;
	start = !start;
	if(start) {
		self.accelerometer.delegate = self;
		[self.accelerometerData release];
		self.accelerometerData = [AccelerometerData alloc];
		n=0; 
		[startStopButton setTitle:@"Stop" forState: UIControlStateNormal];
		[startStopButton setBackgroundImage:[[UIImage imageNamed:@"stop.png"] stretchableImageWithLeftCapWidth:110.0 topCapHeight:0.0] forState:UIControlStateNormal];
		self.accelerometerData.dataX = dataX;
		self.accelerometerData.dataY = dataY;
		self.accelerometerData.dataZ = dataZ;
		self.accelerometerData.minTime = 0.0;
		self.accelerometerData.maxTime = 0.0;
		self.accelerometerData.minX = 0.0;
		self.accelerometerData.maxX = 0.0;
		self.accelerometerData.minY = 0.0;
		self.accelerometerData.maxY = 0.0;
		self.accelerometerData.minZ = 0.0;
		self.accelerometerData.maxZ = 0.0;
		self.accelerometerData.startIndex = 0;
		self.accelerometerData.endIndex = 0;
		
		calibrateX=0.0;
		calibrateY=0.0;
		calibrateZ=0.0;
		
		calibrationN = 0;
		calibrating = calibrationSwitch.on;
		
		self.accelerometerData.newDataSet = TRUE;
		self.accelerometerData.timeInterval = self.accelerometer.updateInterval;
		[startSound play];
	}
	else {
		[startStopButton setTitle:@"Start" forState: UIControlStateNormal];
		[startStopButton setBackgroundImage:[[UIImage imageNamed:@"start.png"] stretchableImageWithLeftCapWidth:110.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[notificationCenter postNotificationName: @"DATACHANGE" object: accelerometerData];
		[stopSound play];
		//		[[UIAccelerometer sharedAccelerometer] setDelegate: nil];
	}
}

-(IBAction) sendButton: (id) sender {
	if(![MFMailComposeViewController canSendMail]) {
		UIAlertView*cantMailAlert=[[UIAlertView alloc] 
								   initWithTitle:@"Can't mail" 
								   message:@"This device not configured for email"
								   delegate: NULL
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:NULL];
		[cantMailAlert show];
		[cantMailAlert release];
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *fileName = [defaults stringForKey:@"File"];
	if(!fileName)
		fileName = @"xyz.csv";
	NSString *email = [defaults stringForKey:@"email"];
	NSArray *recipients; 
	if(!email)
		recipients = [[NSArray alloc] initWithObjects: nil];
	else 
		recipients = [[NSArray alloc] initWithObjects: email, nil];
	
	NSMutableString *string = [[NSMutableString alloc] init];
	[string appendFormat:@"%@\n",@"time,x,y,z"];
	
	for(int i=0;i<n;i++) 
		[string appendFormat:@"%f,%f,%f,%f\n",(float)i*self.accelerometer.updateInterval, dataX[i], dataY[i], dataZ[i]];

	NSData* data;
	data = [string dataUsingEncoding: NSASCIIStringEncoding];
	
	MFMailComposeViewController *mailController = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailController setSubject:@"Acceleration"];
	[mailController setToRecipients:recipients];
	[mailController addAttachmentData:data mimeType:@"text/csv" fileName: fileName];
	mailController.mailComposeDelegate=self;
	[self presentModalViewController:mailController animated:YES];
	[string release];
	[recipients release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller 
		  didFinishWithResult:(MFMailComposeResult)result 
						error:(NSError*)error {
	[controller dismissModalViewControllerAnimated:YES];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	float x = acceleration.x;
	float y = acceleration.y;
	float z = acceleration.z;
	
	if(start) {
		if(calibrating) {
			calibrateX = calibrateX + x;
			calibrateY = calibrateY + y;
			calibrateZ = calibrateZ + z;
			calibrationN++;

			if(calibrationN == (int)(1/self.accelerometer.updateInterval)) {
				calibrateX = calibrateX/calibrationN;
				calibrateY = calibrateY/calibrationN;
				calibrateZ = calibrateZ/calibrationN;
				calibrating = NO;
				[calibrateSound play];
			}
		}		
		else {
			x = x-calibrateX;
			y = y-calibrateY;
			z = z-calibrateZ;
		
			dataX[n]=x;
			dataY[n]=y;
			dataZ[n]=z;
		
			self.accelerometerData.maxTime = n*self.accelerometer.updateInterval;
			if(x < self.accelerometerData.minX) self.accelerometerData.minX = x;
			if(x > self.accelerometerData.maxX) self.accelerometerData.maxX = x;
			if(y < self.accelerometerData.minY) self.accelerometerData.minY = y;
			if(y > self.accelerometerData.maxY) self.accelerometerData.maxY = y;
			if(z < self.accelerometerData.minZ) self.accelerometerData.minZ = z;
			if(z > self.accelerometerData.maxZ) self.accelerometerData.maxZ = z;
		
			self.accelerometerData.endIndex = n;
			self.endIndexSlider.maximumValue = n;
			self.endIndexSlider.value = n;
			NSString *s = [[NSString alloc] initWithFormat:@"%3.2f", n*self.accelerometer.updateInterval];
			endIndexLabel.text=s;
			[s release];		

			if(n % (int)sampleRateSlider.value == 0)
				[notificationCenter postNotificationName: @"DATACHANGE" object: self.accelerometerData];		
			n++;
			self.accelerometerData.newDataSet = FALSE;
			if(n==MAXSAMPLES) {
				start=FALSE;
				[startStopButton setTitle:@"Start" forState: UIControlStateNormal];
			}
		}
	}
	labelX.text = [NSString stringWithFormat:@"%@%3.2f", @"X: ", x];
	labelY.text = [NSString stringWithFormat:@"%@%3.2f", @"Y: ", y];
	labelZ.text = [NSString stringWithFormat:@"%@%3.2f", @"Z: ", z];
	
	self.progressX.progress = (4+x)/8;
	self.progressY.progress = (4+y)/8;
	self.progressZ.progress = (4+z)/8;	
}

-(void) updateData: (NSNotification *) notification { 
	if(self.accelerometerData == nil) return;
	[notificationCenter postNotificationName: @"DATACHANGE" object: self.accelerometerData];		
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	self.accelerometer.delegate = nil;
	start=FALSE;
	[startStopButton setTitle:@"Start" forState: UIControlStateNormal];
}

- (void)viewDidUnload {
	self.accelerometer.delegate = nil;
}

- (void)dealloc {
	self.accelerometer.delegate = nil;
	[accelerometerData release];
	[startSound release];
	[stopSound release];
	[calibrateSound release];	
    [super dealloc];
}

@end
