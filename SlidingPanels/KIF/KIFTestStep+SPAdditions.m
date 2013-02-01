//
//  KIFTestStep+SPAdditions.m
//  SlidingPanels
//
//  Created by John Mcintosh  on 2/1/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import "KIFTestStep+SPAdditions.h"

@implementation KIFTestStep (SPAdditions)

// stackoverflow.com/a/11948460
+ (KIFTestStep*)stepToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    NSString* orientation = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? @"Landscape" : @"Portrait";
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

@end
