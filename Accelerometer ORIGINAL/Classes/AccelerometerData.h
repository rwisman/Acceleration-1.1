#define MAXSAMPLES	120000

@interface AccelerometerData  : NSObject {
	float			minX, maxX, minY, maxY, minZ, maxZ, timeInterval;
	int				startIndex, endIndex;
	Boolean			newDataSet;
	float			*dataX, *dataY, *dataZ; 
}

@property(readwrite, nonatomic) float minX; 
@property(readwrite, nonatomic) float maxX;
@property(readwrite, nonatomic) float minY;
@property(readwrite, nonatomic) float maxY;
@property(readwrite, nonatomic) float minZ;
@property(readwrite, nonatomic) float maxZ;
@property(readwrite, nonatomic) float minTime;
@property(readwrite, nonatomic) float maxTime;
@property(readwrite, nonatomic) int startIndex;
@property(readwrite, nonatomic) int endIndex;
@property(readwrite, nonatomic) float timeInterval;
@property(readwrite, nonatomic) Boolean newDataSet;
@property(readwrite, nonatomic) float *dataX;
@property(readwrite, nonatomic) float *dataY;
@property(readwrite, nonatomic) float *dataZ;
@end

