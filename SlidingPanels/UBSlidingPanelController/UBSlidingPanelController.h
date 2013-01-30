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
@property (nonatomic, strong) UIViewController *leftPanel;
@property (nonatomic, strong) UIViewController *centerPanel;
@property (nonatomic, strong) UIViewController *rightPanel; 

// Container Views
@property (nonatomic, strong) UIView *leftPanelContainer;
@property (nonatomic, strong) UIView *rightPanelContainer;
@property (nonatomic, strong) UIView *centerPanelContainer;

// Public properties
@property(nonatomic, assign) UBSlidingPanelState state;

@end
