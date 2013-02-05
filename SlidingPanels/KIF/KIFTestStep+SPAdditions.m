//
//  KIFTestStep+SPAdditions.m
//  SlidingPanels
//
//  Created by John Mcintosh  on 2/1/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import "KIFTestStep+SPAdditions.h"
#import "UIView-KIFAdditions.h"
#import "AppDelegate.h"


// Expose KIFTestStep internal methods
@interface KIFTestStep ()
+ (UIAccessibilityElement *)_accessibilityElementWithLabel:(NSString *)label accessibilityValue:(NSString *)value tappable:(BOOL)mustBeTappable traits:(UIAccessibilityTraits)traits error:(out NSError **)error;
@end


@implementation KIFTestStep (SPAdditions)

// stackoverflow.com/a/11948460
+ (KIFTestStep *)stepToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    NSString *orientation = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? @"Landscape" : @"Portrait";
    return [KIFTestStep stepWithDescription:[NSString stringWithFormat: @"Rotate to orientation %@", orientation]
                             executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
                                 if( [UIApplication sharedApplication].statusBarOrientation != toInterfaceOrientation ) {
                                     UIDevice* device = [UIDevice currentDevice];
                                     SEL message = NSSelectorFromString(@"setOrientation:");
                                     
                                     if( [device respondsToSelector: message] ) {
                                         NSMethodSignature* signature = [UIDevice instanceMethodSignatureForSelector:message];
                                         NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
                                         [invocation setTarget:device];
                                         [invocation setSelector:message];
                                         [invocation setArgument:&toInterfaceOrientation atIndex:2];
                                         [invocation invoke];
                                     }
                                 }
                                 
                                 return KIFTestStepResultSuccess;
                             }];
}



//+ (KIFTestStep *)stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:(NSString *)accessibilityLabel {
//    
//}


+ (id)stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:(NSString *)label;
{
    return [self stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:label traits:UIAccessibilityTraitNone];
}

+ (id)stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:(NSString *)label traits:(UIAccessibilityTraits)traits;
{
    return [self stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:label value:nil traits:traits];
}

+ (id)stepToWaitForAbsenceOfTappableViewWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits;
{
    NSString *description = nil;
    if (value.length) {
        description = [NSString stringWithFormat:@"Wait for absence of tappable view with accessibility label \"%@\" and accessibility value \"%@\"", label, value];
    } else {
        description = [NSString stringWithFormat:@"Wait for absence of tappable view with accessibility label \"%@\"", label];
    }
    
    return [self stepWithDescription:description executionBlock:^(KIFTestStep *step, NSError **error) {
        UIAccessibilityElement *element = [self _accessibilityElementWithLabel:label accessibilityValue:value tappable:NO traits:traits error:error];
        return (element ? KIFTestStepResultSuccess : KIFTestStepResultWait);
    }];
}


/*
+ (KIFTestStep *)stepToConfirmViewWithAccessibilityLabelIsTappable:(NSString *)accessibilityLabel {
    return [KIFTestStep stepWithDescription:@"Confirm View is Not Covered" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIWindow *window = appDelegate.window;
        UIView *viewUnderTest = (UIView *)[window accessibilityElementWithLabel:accessibilityLabel];
        if ( [viewUnderTest isTappable] ) {
            return KIFTestStepResultSuccess;
        }
        
        NSDictionary *errorDictionary = @{@"NSLocalizedDescription": @"The test view is not tappable"};
        *error = [NSError errorWithDomain:@"KIFTest" code:0 userInfo:errorDictionary];
        return KIFTestStepResultFailure;
    }];
}


+ (KIFTestStep *)stepToConfirmViewWithAccessibilityLabelIsNotTappable:(NSString *)accessibilityLabel {
    return [KIFTestStep stepWithDescription:@"Confirm View is Not Covered" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIWindow *window = appDelegate.window;
        UIView *viewUnderTest = (UIView *)[window accessibilityElementWithLabel:accessibilityLabel];
        if ( ![viewUnderTest isTappable] ) {
            return KIFTestStepResultSuccess;
        }
        
        NSDictionary *errorDictionary = @{@"NSLocalizedDescription": @"The test view is tappable"};
        *error = [NSError errorWithDomain:@"KIFTest" code:0 userInfo:errorDictionary];
        return KIFTestStepResultFailure;
    }];
}
*/

/*
+ (KIFTestStep *)stepToConfirmViewWithAccessibilityLabelIsNotCovered:(NSString *)accessibilityLabel {
    return [KIFTestStep stepWithDescription:@"Confirm View is Not Covered" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        
        // Grab Views we need
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIWindow *window = appDelegate.window;
        UIView *viewUnderTest = (UIView *)[window accessibilityElementWithLabel:accessibilityLabel];
        
        // Start at the bottom of the view stack
        for (NSUInteger i=0; i<window.subviews.count; i++) {

            UIView *currentSubview = [window.subviews objectAtIndex:i];
            
            // We're only interested in everything that starts above the view that contains this view
            if ( [viewUnderTest isDescendantOfView:currentSubview] ) {
                
            }
            
            CGRect rectTestViewInWindow = [viewUnderTest convertRect:viewUnderTest.bounds toView:nil];
            CGRect rectCurrentViewInWindow = [currentView convertRect:currentView.bounds toView:nil];
            
            // View is covered if a view above it intersects its frame
            if ( CGRectIntersectsRect(rectTestViewInWindow, rectCurrentViewInWindow) ) {
                
                NSDictionary *errorDictionary = @{@"NSLocalizedDescription": @"There is a view above the test view that at least partially covers the test view."};
                *error = [NSError errorWithDomain:@"KIFTest" code:0 userInfo:errorDictionary];
                return KIFTestStepResultFailure;
            }
        }
        
        return KIFTestStepResultSuccess;
    }];
}

//- (KIFTestStep *)stepToConfirmViewWithAccessibilityLabelIsCovered:(NSString *)accessibilityLabel {
//    return [KIFTestStep stepWithDescription:@"" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
//        
//    }];
//}
*/

@end
