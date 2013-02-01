//
//  UBSlidingPanelController.h
//  SlidingPanels
//
//  Created by John Mcintosh  on 1/30/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UBSlidingPanelCenterOnly,
    UBSlidingPanelLeftVisible,
    UBSlidingPanelRightVisible
} UBSlidingPanelState;

@interface UBSlidingPanelController : UIViewController <UIGestureRecognizerDelegate>

// View Controllers
@property (nonatomic, strong) UIViewController *leftPanelVC;
@property (nonatomic, strong) UIViewController *centerPanelVC;
@property (nonatomic, strong) UIViewController *rightPanelVC; 

// Container Views
@property (nonatomic, strong) UIView *leftPanelContainerView;
@property (nonatomic, strong) UIView *rightPanelContainerView;
@property (nonatomic, strong) UIView *centerPanelContainerView;

// Public properties
@property(nonatomic, assign) UBSlidingPanelState state;

@end
