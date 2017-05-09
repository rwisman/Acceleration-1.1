//
//  Created by Ray Wisman on July 31, 2010.
//

#import "AccelerometerData.h"

@implementation AccelerometerData

@synthesize dataX;
@synthesize dataY;
@synthesize dataZ;
@synthesize minX;
@synthesize maxX;
@synthesize minY;
@synthesize maxY;
@synthesize minZ;
@synthesize maxZ;
@synthesize minTime;
@synthesize maxTime;
@synthesize newDataSet;
@synthesize timeInterval;
@synthesize startIndex;
@synthesize endIndex;


- (void)dealloc {
    [super dealloc];
}

@end
