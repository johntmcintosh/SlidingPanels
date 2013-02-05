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

    // Portrait
    [scenario addStep:[KIFTestStep stepToInterfaceOrientation:UIInterfaceOrientationPortrait]];
    
    // Starts with left panel visible
    // Tap center panel should put center panel in the middle
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Center Panel Overlay"]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:@"Left Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:@"Right Panel"]];
    
    // Toggle should re-show left panel
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Toggle Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Left Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:@"Right Panel"]];    

    // Swipe should put center panel in middle
    [scenario addStep:[KIFTestStep stepToSwipeViewWithAccessibilityLabel:@"Center Panel" inDirection:KIFSwipeDirectionLeft]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:@"Left Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:@"Right Panel"]];

    // Swipe should show left panel
    [scenario addStep:[KIFTestStep stepToSwipeViewWithAccessibilityLabel:@"Center Panel" inDirection:KIFSwipeDirectionRight]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Left Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:@"Right Panel"]];

    // Lanscape
    [scenario addStep:[KIFTestStep stepToInterfaceOrientation:UIInterfaceOrientationLandscapeRight]];

    // Toggle should move panel to show right
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Toggle Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:@"Left Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Right Panel"]];

    // Toggle should move panel to show left
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Toggle Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Left Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Center Panel"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:@"Right Panel"]];
    
    return scenario;
}

@end
