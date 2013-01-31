//
//  UBSlidingPanelController.m
//  SlidingPanels
//
//  Created by John Mcintosh  on 1/30/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import "UBSlidingPanelController.h"

@interface UBSlidingPanelController ()
@property(nonatomic, assign) CGPoint locationBeforePan;
@property(nonatomic, assign) BOOL allowRightOverpan;
@property(nonatomic, assign) BOOL allowLeftOverpan;
@property(nonatomic, assign) CGPoint dragTouchStart;
@property(nonatomic, assign) BOOL centerPanelIsDragging;

// the minimum % of total screen width the centerPanel.view must move for panGesture to succeed
@property (nonatomic) CGFloat minimumMovePercentage;

// the maximum time panel opening/closing should take. Actual time may be less if panGesture has already moved the view.
@property (nonatomic) CGFloat maximumAnimationDuration;

// how long the bounce animation should take
@property (nonatomic) CGFloat bounceDuration;

// how far the view should bounce
@property (nonatomic) CGFloat bouncePercentage;

@end

static CGFloat kCenterPanelWidth = 768.0f;
static CGFloat kSidePanelWidth = 1024.0f - 768.0f;
static char kvoContext;

@implementation UBSlidingPanelController

- (id)init
{
    self = [super init];
    if (self) {
        
        // State
        self.state = UBSlidingPanelLeftVisible;
        self.allowRightOverpan = NO;
        self.allowLeftOverpan = NO;
        self.dragTouchStart = CGPointZero;
        self.centerPanelIsDragging = NO;
        
        self.minimumMovePercentage = 0.15f;
        self.maximumAnimationDuration = 0.2f;
        self.bounceDuration = 0.1f;
        self.bouncePercentage = 0.075f;
    }
    return self;
}


//
// viewDidLoad
//
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Create container views
    self.centerPanelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCenterPanelWidth, CGRectGetHeight(self.view.bounds))];
    self.leftPanelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSidePanelWidth, CGRectGetHeight(self.view.bounds))];
    self.rightPanelContainer = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-kSidePanelWidth, 0, kSidePanelWidth, CGRectGetHeight(self.view.bounds))];
    [self configureContainers];
    
    // Add as Subviews
    [self.view addSubview:self.centerPanelContainer];
    [self.view addSubview:self.leftPanelContainer];
    [self.view addSubview:self.rightPanelContainer];
    [self.view bringSubviewToFront:self.centerPanelContainer];
}

//
// viewWillAppear:
//
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Add Content
    [self _addChildVC:self.leftPanel intoView:self.leftPanelContainer];
    [self _addChildVC:self.rightPanel intoView:self.rightPanelContainer];
    [self _addChildVC:self.centerPanel intoView:self.centerPanelContainer];
    
    // Layout
    [self positionCenterContainerForState:self.state animated:NO];
    
    // Gestures
    [self _addTapGestureToView:self.centerPanelContainer];
//    [self _addPanGestureToView:self.centerPanelContainer];
}

//
// didReceiveMemoryWarning
//
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setters

//
// setState:
//
- (void)setState:(UBSlidingPanelState)state
{
    _state = state;
    [self positionCenterContainerForState:state animated:YES];
}

#pragma mark - Private

//
// configureContainers
//
- (void)configureContainers
{
    self.leftPanelContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.rightPanelContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.centerPanelContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

//
// positionCenterContainerForState:
//
- (void)positionCenterContainerForState:(UBSlidingPanelState)state animated:(BOOL)animated
{
    CGRect centerFrame = self.centerPanelContainer.frame;
    
    switch (state) {
        case UBSlidingPanelCenterOnly:
            // CenterOnly will also show right panel in landscape
            centerFrame.origin.x = 0.0f;
            break;
        case UBSlidingPanelLeftVisible:
            centerFrame.origin.x = CGRectGetWidth(self.leftPanelContainer.frame);
            break;
        case UBSlidingPanelRightVisible:
            centerFrame.origin.x = (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) ? 0.0f : -kSidePanelWidth;
            break;
        default:
            break;
    }
    
    CGFloat duration = (animated) ? 0.25 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.centerPanelContainer.frame = centerFrame;
    }];
}


#pragma mark - Panels

- (void)setCenterPanel:(UIViewController *)centerPanel {

    if (centerPanel != _centerPanel) {
        [_centerPanel removeObserver:self forKeyPath:@"view"];
        [_centerPanel removeObserver:self forKeyPath:@"viewControllers"];
        _centerPanel = centerPanel;
//        [_centerPanel addObserver:self forKeyPath:@"viewControllers" options:0 context:&kvoContext];
//        [_centerPanel addObserver:self forKeyPath:@"view" options:NSKeyValueObservingOptionInitial context:&kvoContext];
    }

    if (centerPanel != _centerPanel) {
        [self _removeChildVC:_centerPanel];
        if (centerPanel) {
            [self _addChildVC:centerPanel intoView:self.centerPanelContainer];
        }
    }
}


- (void)setLeftPanel:(UIViewController *)leftPanel {
    if (leftPanel != _leftPanel) {
        [self _removeChildVC:_leftPanel];
        _leftPanel = leftPanel;
        if (_leftPanel) {
            [self _addChildVC:leftPanel intoView:self.leftPanelContainer];
        }
    }
}

- (void)setRightPanel:(UIViewController *)rightPanel {
    if (rightPanel != _rightPanel) {
        [self _removeChildVC:_rightPanel];
        _rightPanel = rightPanel;
        if (_rightPanel) {
            [self _addChildVC:rightPanel intoView:self.rightPanelContainer];
        }
    }
}

#pragma mark - Private

- (void)_removeChildVC:(UIViewController *)vc
{
    [vc willMoveToParentViewController:nil];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}

- (void)_addChildVC:(UIViewController *)vc intoView:(UIView *)targetView
{
    [self addChildViewController:vc];
    [targetView addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}


#pragma mark - Gesture Recognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] ) {
        return YES;
    }
    
    // Make sure panning horizontally
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translate = [pan translationInView:self.centerPanelContainer];
        BOOL possible = translate.x != 0 && ((fabsf(translate.y) / fabsf(translate.x)) < 1.0f);
        if (possible && ((translate.x > 0 && self.leftPanel) || (translate.x < 0 && self.rightPanel))) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Tap Gestures

//
// _addTapGestureToView:
//
- (void)_addTapGestureToView:(UIView *)view
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    [view addGestureRecognizer:tapGesture];
}

//
// _handleTap:
//
- (void)_handleTap:(UITapGestureRecognizer *)tapRecognizer
{
    UBSlidingPanelState nextState;
    
    switch (self.state) {
        case UBSlidingPanelCenterOnly:
            nextState = UBSlidingPanelLeftVisible;
            break;
        case UBSlidingPanelLeftVisible:
            nextState = UBSlidingPanelCenterOnly;
            break;
        case UBSlidingPanelRightVisible:
            nextState = UBSlidingPanelCenterOnly;
            break;
        default:
            nextState = UBSlidingPanelCenterOnly;
            break;
    }
    
    self.state = nextState;
}


#pragma mark - Manual Touch Handling

//
// touchesBegan: withEvent:
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.centerPanelContainer];
    
    if ( CGRectContainsPoint(self.centerPanelContainer.bounds, point) ) {
        self.centerPanelIsDragging = YES;
        self.dragTouchStart = point;
    }
    else {
        self.centerPanelIsDragging = NO;
    }
}

//
// touchesMoved: withEvent:
//
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint pointInCenterPanel = [touch locationInView:self.centerPanelContainer];
    
    if ( self.centerPanelIsDragging) {
    
        CGFloat maxOriginX = kSidePanelWidth;
        CGFloat minOriginX = CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.centerPanelContainer.frame) - kSidePanelWidth;
        
        CGFloat xMovementSinceStarted = pointInCenterPanel.x - self.dragTouchStart.x;
        CGFloat newOriginX = CGRectGetMinX(self.centerPanelContainer.frame) + xMovementSinceStarted;
        
        // Constraints
        // Let's compute how far the drag is beyond the sidebar size. Then, we'll multiple that distance
        // by a spring constant to give an elasticity to the drag that's beyond the boundary
        CGFloat springValue = 0.1f;
        CGFloat constrainedNewOriginX = newOriginX;
        if ( constrainedNewOriginX > maxOriginX ) {
            CGFloat amountBeyondMax = newOriginX - maxOriginX;
            constrainedNewOriginX = maxOriginX + (springValue*amountBeyondMax);
        }
        else if ( constrainedNewOriginX < minOriginX ) {
            CGFloat amountBeforeMin = minOriginX - newOriginX;
            constrainedNewOriginX = minOriginX - (springValue*amountBeforeMin);
        }
        
        // Update the frame
        CGRect frame = self.centerPanelContainer.frame;
        frame.origin.x = constrainedNewOriginX;
        self.centerPanelContainer.frame = frame;
    }
    else {
        [super touchesMoved:touches withEvent:event];
    }
}

//
// touchesEnded: withEvent:
//
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( self.centerPanelIsDragging ) {
        
        //
        [self positionCenterContainerForState:[self targetStateForCenterPanel] animated:YES];

        // Reset Vars
        self.dragTouchStart = CGPointZero;
        self.centerPanelIsDragging = NO;
    }
    else {
        
    }
    [super touchesEnded:touches withEvent:event];
}

//
// targetStateForCenterPanel
// When we end dragging, we need to look at where the panel currently is,
// and determine what state that corresponds to
//
- (UBSlidingPanelState)targetStateForCenterPanel
{
    CGFloat centerOriginX = CGRectGetMinX(self.centerPanelContainer.frame);
    
    if ( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ) {
        if ( centerOriginX < (kSidePanelWidth/2) ) {
            return UBSlidingPanelRightVisible;
        }
        else {
            return UBSlidingPanelLeftVisible;
        }
    }
    else {
        if ( centerOriginX < -(kSidePanelWidth/2) ) {
            return UBSlidingPanelRightVisible;
        }
        else if ( centerOriginX < (kSidePanelWidth/2) ) {
            return UBSlidingPanelCenterOnly;
        }
        else {
            return UBSlidingPanelLeftVisible;
        }
    }
}

#pragma mark - Pan Gestures

/*
//
// _addPanGestureToView:
//
- (void)_addPanGestureToView:(UIView *)view
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [view addGestureRecognizer:panGesture];
}


//
// _handlePan:
//
- (void)_handlePan:(UIGestureRecognizer *)sender
{
    if ([sender isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
        
        if (pan.state == UIGestureRecognizerStateBegan) {
            _locationBeforePan = self.centerPanelContainer.frame.origin;
        }
        
        CGPoint translate = [pan translationInView:self.centerPanelContainer];
        CGRect frame = self.centerPanelContainer.frame;
        frame.origin.x += [self _correctMovement:translate.x];
        self.centerPanelContainer.frame = frame;
        
        if (sender.state == UIGestureRecognizerStateEnded) {
            CGFloat deltaX =  frame.origin.x - _locationBeforePan.x;
            if ([self _validateThreshold:deltaX]) {
                [self _completePan:deltaX];
            } else {
                [self _undoPan];
            }
        } else if (sender.state == UIGestureRecognizerStateCancelled) {
            [self _undoPan];
        }
    }
}
*/

- (void)_completePan:(CGFloat)deltaX {
    /*
    switch (self.state) {
        case JASidePanelCenterVisible: {
            if (deltaX > 0.0f) {
                [self _showLeftPanel:YES bounce:self.bounceOnSidePanelOpen];
            } else {
                [self _showRightPanel:YES bounce:self.bounceOnSidePanelOpen];
            }
            break;
		}
        case JASidePanelLeftVisible: {
            [self _showCenterPanel:YES bounce:self.bounceOnSidePanelClose];
            break;
		}
        case JASidePanelRightVisible: {
            [self _showCenterPanel:YES bounce:self.bounceOnSidePanelClose];
            break;
		}
    }
     */
}

- (void)_undoPan {
    /*
    switch (self.state) {
        case JASidePanelCenterVisible: {
            [self _showCenterPanel:YES bounce:NO];
            break;
		}
        case JASidePanelLeftVisible: {
            [self _showLeftPanel:YES bounce:NO];
            break;
		}
        case JASidePanelRightVisible: {
            [self _showRightPanel:YES bounce:NO];
		}
    }
     */
}

/*
- (CGFloat)_correctMovement:(CGFloat)movement {
    
    CGRect _centerPanelRestingFrame = CGRectMake(0, 0, 768, CGRectGetHeight(self.view.bounds));
    CGFloat position = _centerPanelRestingFrame.origin.x + movement;
    if (self.state == UBSlidingPanelCenterOnly) {
        if ((position > 0.0f && !self.leftPanel) || (position < 0.0f && !self.rightPanel)) {
            return 0.0f;
        }
    } else if (self.state == UBSlidingPanelRightVisible && !self.allowRightOverpan) {
        if ((position + _centerPanelRestingFrame.size.width) < (self.rightPanelContainer.frame.size.width - kSidePanelWidth)) {
            return 0.0f;
        } else if (position > self.rightPanelContainer.frame.origin.x) {
            return self.rightPanelContainer.frame.origin.x - _centerPanelRestingFrame.origin.x;
        }
    } else if (self.state == UBSlidingPanelLeftVisible  && !self.allowLeftOverpan) {
        if (position > kSidePanelWidth) {
            return 0.0f;
        } else if (position < self.leftPanelContainer.frame.origin.x) {
            return  self.leftPanelContainer.frame.origin.x - _centerPanelRestingFrame.origin.x;
        }
    }

    return movement;
}

- (BOOL)_validateThreshold:(CGFloat)movement {
    CGFloat minimum = floorf(self.view.bounds.size.width * self.minimumMovePercentage);
    switch (self.state) {
        case UBSlidingPanelLeftVisible: {
            return movement <= -minimum;
		}
        case UBSlidingPanelCenterOnly: {
            return fabsf(movement) >= minimum;
		}
        case UBSlidingPanelRightVisible: {
            return movement >= minimum;
		}
    }
    return NO;
}
*/

@end
