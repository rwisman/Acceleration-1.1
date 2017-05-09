//
//  AppDelegate.m
//  CPTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.
//
//  Modified by Ray Wisman on July 31, 2010.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		[window setFrame:CGRectMake(0, 0, 320, 480)];
	}else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[window setFrame:CGRectMake(0, 0, 768, 1024)];
	}
	
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
}

-(void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

