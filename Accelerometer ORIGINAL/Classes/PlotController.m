//
//  PlotController.m
//
//  Created by Ray Wisman on July 31, 2010.
//

#import "PlotController.h"

@implementation PlotController

@synthesize startSlider, endSlider;
@synthesize accelerationData;
@synthesize notificationCenter;
@synthesize accelerometerData;
@synthesize accelerationPlot, velocityPlot, distancePlot;
@synthesize plotAcceleration, plotVelocity, plotDistance;
@synthesize start, end, y, v, t, sizeChanged;

#pragma mark -
#pragma mark Initialization and teardown

- (BOOL)shouldAutorotateToInterfaceOrientation:
	(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(void)dealloc 
{
	[accelerationPlot release];
	[velocityPlot release];
	[distancePlot release];
	[graph release];
    [super dealloc];
}

-(IBAction) endSizeSliderAction: (id) sender {
	UISlider *slider = (UISlider *) sender;
	sizeChanged = YES;
	end = self.accelerometerData.endIndex * slider.value;
	if(end < start)
		end = start;
	[self updatePlot];
}

-(IBAction) startSizeSliderAction: (id) sender {
	UISlider *slider = (UISlider *) sender;
	sizeChanged = YES;
	start = self.accelerometerData.endIndex * slider.value;
	if(start > end)
		start = end;
	[self updatePlot];
}

-(IBAction) toggleAcclerationPlotAction: (id) sender {
	plotAcceleration = !plotAcceleration;
	if(plotAcceleration)
		[graph addPlot:accelerationPlot];
	else
		[graph removePlot:accelerationPlot];
	[self updatePlot];
}

-(IBAction) toggleVelocityPlotAction: (id) sender {
	plotVelocity = !plotVelocity;
	if(plotVelocity)
		[graph addPlot:velocityPlot];
	else
		[graph removePlot:velocityPlot];
	[self updatePlot];
	
}

-(IBAction) toggleDistancePlotAction: (id) sender {
	plotDistance = !plotDistance;
	if(plotDistance)
		[graph addPlot:distancePlot];
	else
		[graph removePlot:distancePlot];
	[self updatePlot];
}

-(void)viewDidLoad {
    [super viewDidLoad];	
	
	self.accelerometerData = nil;
	self.plotAcceleration = YES;
	self.plotVelocity = YES;
	self.plotDistance = YES;
	
	sizeChanged = NO;
    
	start = 0;					// Starting index of plot data
	end = 0;					// Ending index of plot data
	
    // Create graph from theme
    graph = [[CPXYGraph alloc] initWithFrame: CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
    [graph applyTheme:theme];	
	graph.plotAreaFrame.masksToBorder = YES;
    graph.paddingLeft = 10.0;
	graph.paddingTop = 10.0;
	graph.paddingRight = 10.0;
	graph.paddingBottom = 110.0;

    CPLayerHostingView *hostingView = [[CPLayerHostingView alloc] initWithFrame: CGRectZero];
	hostingView.userInteractionEnabled = YES;
    hostingView.hostedLayer = graph;	
	[self.view addSubview:hostingView];
	[hostingView release];
	
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SizingView" owner:self options:nil];
	UIView *sizingView = [nib objectAtIndex:0];
	sizingView.backgroundColor = [UIColor clearColor];
	
	sizingView.frame = self.view.bounds;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		graph.paddingBottom = 120.0;
		// Change slider thumb to clock image
		[endSlider setThumbImage:[UIImage imageNamed:@"clock-22x22.png"] forState:UIControlStateNormal];
		[startSlider setThumbImage:[UIImage imageNamed:@"clock-22x22.png"] forState:UIControlStateNormal];
	}else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		graph.paddingBottom = 140.0;
		// Change slider thumb to clock image
//		iPad slider disappears when thumb image set 
//		[endSlider setThumbImage:[UIImage imageNamed:@"clock-32x32.png"] forState:UIControlStateNormal];
//		[startSlider setThumbImage:[UIImage imageNamed:@"clock-32x32.png"] forState:UIControlStateNormal];
	}
	
	[self.view addSubview: sizingView];
	
	
	// Root view rotated about the x-axis 180 degrees by Core-Plot for compatibility with Mac, un-rotate 180.
	self.view.transform = CGAffineTransformMakeScale(1,-1);	
	
	// Create a blue Acceleration area
	accelerationPlot = [[CPScatterPlot alloc] init];
    accelerationPlot.identifier = @"Acceleration";
	accelerationPlot.dataLineStyle.miterLimit = 1.0f;
	accelerationPlot.dataLineStyle.lineWidth = 2.0f;
	accelerationPlot.dataLineStyle.lineColor = [CPColor blueColor];
    accelerationPlot.dataSource = self;
	[graph addPlot:accelerationPlot];
	
    // Create a green Velocity area
	velocityPlot = [[CPScatterPlot alloc] init];
    velocityPlot.identifier = @"Velocity";
	velocityPlot.dataLineStyle.lineWidth = 2.0f;
    velocityPlot.dataLineStyle.lineColor = [CPColor greenColor];
    velocityPlot.dataSource = self;
    [graph addPlot:velocityPlot];
	
    // Create a red distance area
	distancePlot = [[CPScatterPlot alloc] init];
    distancePlot.identifier = @"Distance";
	distancePlot.dataLineStyle.lineWidth = 2.0f;
    distancePlot.dataLineStyle.lineColor = [CPColor redColor];
    distancePlot.dataSource = self;
    [graph addPlot:distancePlot];
	
	self.notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter addObserver: self 
						   selector: @selector(updatePlot:) 
							   name: @"DATACHANGE" 
							 object: nil];
	
	[notificationCenter postNotificationName: @"DATAREQUEST" object: nil];		
}

-(void) updatePlot {	
	if(self.accelerometerData == nil) return;			// Nothing to plot
	if( !sizeChanged ) {
		end = self.accelerometerData.endIndex;
		start = self.accelerometerData.startIndex;
	}
		
	self.v=0.0;
	self.y=0.0;
	self.t = self.accelerometerData.timeInterval;
	
	float vv = 0.0;
	float yy = 0.0;
	
	float maxY=0.0, minY=0.0;
	
	if(plotAcceleration) {
		maxY = accelerationData[start];
		minY = accelerationData[start];
	}
	
	for(int i=start;i<=end; i=i+interval) {
		float a = accelerationData[i] * 9.8;
		vv = vv+a*t;
		
		yy=yy+vv*t+0.5*a*t*t;						//	yo+vt+1/2at^2 
		
		if(plotAcceleration) {
			if(accelerationData[i] > maxY) maxY = accelerationData[i];
			if(accelerationData[i] < minY) minY = accelerationData[i];
		}
		
		if(plotVelocity) {
			if(vv > maxY) maxY = vv;
			if(vv < minY) minY = vv;
		}
		
		if(plotDistance) {
			if(yy > maxY) maxY = yy;
			if(yy < minY) minY = yy;
		}
	}
	
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	
	plotSpace.allowsUserInteraction = YES;
	
    plotSpace.xRange = [CPPlotRange 
						plotRangeWithLocation:CPDecimalFromFloat(start*self.accelerometerData.timeInterval-(end-start)*self.accelerometerData.timeInterval/10.0) 
						length:CPDecimalFromFloat((end-start)*self.accelerometerData.timeInterval+(end-start)*self.accelerometerData.timeInterval/10.0)];
	
    plotSpace.yRange = [CPPlotRange 
						plotRangeWithLocation:CPDecimalFromFloat(minY-(maxY-minY)/10.0) 
						length:CPDecimalFromFloat(maxY-minY+(maxY-minY)/5.0)];
	
    // Grid line styles
    CPLineStyle *majorGridLineStyle = [CPLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.25];
    
    CPLineStyle *minorGridLineStyle = [CPLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPColor blackColor] colorWithAlphaComponent:0.1]; 
	
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *xAxis = axisSet.xAxis;
    xAxis.majorIntervalLength = CPDecimalFromFloat(((end-start)*self.accelerometerData.timeInterval)/4);
    xAxis.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");
    xAxis.minorTicksPerInterval = 4;
	xAxis.title = @"Time";
    xAxis.majorGridLineStyle = majorGridLineStyle;
    xAxis.minorGridLineStyle = minorGridLineStyle;
	
    CPXYAxis *yAxis = axisSet.yAxis;
    yAxis.majorIntervalLength = CPDecimalFromFloat((maxY-minY)/4.0);
    yAxis.minorTicksPerInterval = 4;
    yAxis.orthogonalCoordinateDecimal = CPDecimalFromFloat(start*self.accelerometerData.timeInterval);
    yAxis.majorGridLineStyle = majorGridLineStyle;
    yAxis.minorGridLineStyle = minorGridLineStyle;
	yAxis.labelRotation = -M_PI/3.0;	
	
	[graph reloadData];	
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
 	if(self.accelerometerData == nil) return 0;			// Nothing to plot
	return (end-start)/interval+1;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{		
	if (index == 0) {
		self.v = 0.0;
		self.y = 0.0;
		self.t = self.accelerometerData.timeInterval;
	}
	index = index * interval;
	
	if(fieldEnum == CPScatterPlotFieldX)
		return [NSNumber numberWithFloat:((index+start)*self.accelerometerData.timeInterval)];
	if ([(NSString *)plot.identifier isEqualToString:@"Acceleration"]) 
		return [NSNumber numberWithFloat: self.accelerationData[index+start]];
	if ([(NSString *)plot.identifier isEqualToString:@"Velocity"]) {
		NSNumber *vNumber = [NSNumber numberWithFloat:self.v];
		self.v = self.v+accelerationData[index+start]*9.8*self.t;
		return vNumber;
	}
	if ([(NSString *)plot.identifier isEqualToString:@"Distance"]) {
		NSNumber *yNumber = [NSNumber numberWithFloat:self.y];
		self.v = self.v+self.accelerationData[index+start]*9.8*self.t;												// velocity
		self.y = self.y+self.v*self.t+0.5*self.accelerationData[index+start]*9.8*self.t*self.t;						// distance:	yn=yn-1+vt+1/2at^2 
		return yNumber;
	}
	
    return nil;
}

@end
