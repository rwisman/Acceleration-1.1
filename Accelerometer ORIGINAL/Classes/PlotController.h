#import "CorePlot-CocoaTouch.h"
#import "AccelerometerData.h"

#define numberDataPointstoPlot	250
#define interval	((end-start) / numberDataPointstoPlot + 1)			

@interface PlotController : UIViewController <CPPlotDataSource>
{
	CPXYGraph *graph;
	
	float *accelerationData;
	
	float y, v, t;
	
	int start, end;
	
	IBOutlet UISlider *startSlider, *endSlider;

	AccelerometerData *accelerometerData;
	
	NSNotificationCenter *notificationCenter;
	
	Boolean sizeChanged, plotAcceleration;
	
	CPScatterPlot *accelerationPlot;
}

@property (nonatomic, retain) IBOutlet UISlider *startSlider;
@property (nonatomic, retain) IBOutlet UISlider *endSlider;
@property(readwrite, nonatomic) float *accelerationData;
@property(readwrite, nonatomic) int start;
@property(readwrite, nonatomic) int end;
@property(readwrite, nonatomic) Boolean sizeChanged;
@property(readwrite, nonatomic) Boolean plotAcceleration, plotVelocity, plotDistance;
@property(readwrite, nonatomic) float y;
@property(readwrite, nonatomic) float v;
@property(readwrite, nonatomic) float t;
@property(readwrite, retain, nonatomic) NSNotificationCenter *notificationCenter;
@property(readwrite, retain, nonatomic) AccelerometerData *accelerometerData;
@property(readwrite, retain, nonatomic) CPScatterPlot *accelerationPlot, *velocityPlot, *distancePlot;

-(IBAction) endSizeSliderAction: (id) sender;
-(IBAction) startSizeSliderAction: (id) sender;
-(IBAction) startSizeSliderAction: (id) sender;
-(IBAction) toggleAcclerationPlotAction: (id) sender;
-(IBAction) toggleVelocityPlotAction: (id) sender;
-(IBAction) toggleDistancePlotAction: (id) sender;
-(void) updatePlot;

@end
