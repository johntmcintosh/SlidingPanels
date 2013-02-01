//
//  SPKIFTestController.m
//  SlidingPanels
//
//  Created by John Mcintosh  on 2/1/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import "SPKIFTestController.h"
#import "KIFTestScenario+SPAdditions.h"

@implementation SPKIFTestController

- (void)initializeScenarios;
{
    [self addScenario:[KIFTestScenario scenarioToToggleCenterPanel]];
    // Add additional scenarios you want to test here
}

@end
