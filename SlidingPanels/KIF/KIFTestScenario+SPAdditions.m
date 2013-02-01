//
//  KIFTestScenario+SPAdditions.m
//  SlidingPanels
//
//  Created by John Mcintosh  on 2/1/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import "KIFTestScenario+SPAdditions.h"
#import "KIFTestStep.h"
#import "KIFTestStep+SPAdditions.h"

@implementation KIFTestScenario (SPAdditions)

+ (id)scenarioToToggleCenterPanel
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can successfully log in."];

    [scenario addStep:[KIFTestStep stepToInterfaceOrientation:UIInterfaceOrientationPortrait]];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Toggle Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForTimeInterval:1.0 description:@"Wait for animation"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Toggle Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForTimeInterval:1.0 description:@"Wait for animation"]];
    [scenario addStep:[KIFTestStep stepToSwipeViewWithAccessibilityLabel:@"Center Panel" inDirection:KIFSwipeDirectionLeft]];
    [scenario addStep:[KIFTestStep stepToSwipeViewWithAccessibilityLabel:@"Center Panel" inDirection:KIFSwipeDirectionRight]];

    [scenario addStep:[KIFTestStep stepToInterfaceOrientation:UIInterfaceOrientationLandscapeRight]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Toggle Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForTimeInterval:1.0 description:@"Wait for animation"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Toggle Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForTimeInterval:1.0 description:@"Wait for animation"]];
    [scenario addStep:[KIFTestStep stepToSwipeViewWithAccessibilityLabel:@"Center Panel" inDirection:KIFSwipeDirectionLeft]];
    [scenario addStep:[KIFTestStep stepToSwipeViewWithAccessibilityLabel:@"Center Panel" inDirection:KIFSwipeDirectionRight]];

    return scenario;
}

@end
