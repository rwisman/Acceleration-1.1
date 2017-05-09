#import "XPlotController.h"

@implementation XPlotController

-(void) updatePlot: (NSNotification *) notification { 
	
	self.accelerometerData = (AccelerometerData *)[ notification object ];
	self.accelerationData = accelerometerData.dataX;	
	
	sizeChanged = NO;
	[self updatePlot ];
}

@end
