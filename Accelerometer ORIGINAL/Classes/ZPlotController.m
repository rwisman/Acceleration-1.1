#import "ZPlotController.h"

@implementation ZPlotController

-(void) updatePlot: (NSNotification *) notification { 
	
	accelerometerData = (AccelerometerData *)[ notification object ];
	self.accelerationData = accelerometerData.dataZ;	
	
	sizeChanged = NO;
	[self updatePlot ];
}

@end
