#import "YPlotController.h"

@implementation YPlotController

-(void) updatePlot: (NSNotification *) notification { 
	
	accelerometerData = (AccelerometerData *)[ notification object ];
	self.accelerationData = accelerometerData.dataY;	
	
	sizeChanged = NO;
	[self updatePlot ];
}

@end
