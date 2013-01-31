//
//  UBSlidingPanelController.m
//  SlidingPanels
//
//  Created by John Mcintosh  on 1/30/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import "UBSlidingPanelController.h"
#import <QuartzCore/QuartzCore.h>


@interface UBSlidingPanelController ()
@property(nonatomic, assign) CGPoint locationBeforePan;
@property(nonatomic, assign) BOOL allowRightOverpan;
@property(nonatomic, assign) BOOL allowLeftOverpan;
@property(nonatomic, assign) CGPoint dragTouchStart;
@property(nonatomic, assign) BOOL centerPanelIsDragging;
@property(nonatomic, assign) CGPoint initialCenterPanelOrigin;

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
static CGFloat kSidePanelPadding = 50.0f;

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
    self.leftPanelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSidePanelWidth+kSidePanelPadding, CGRectGetHeight(self.view.bounds))];
    self.rightPanelContainer = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-kSidePanelWidth-kSidePanelPadding, 0, kSidePanelWidth+kSidePanelPadding, CGRectGetHeight(self.view.bounds))];
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
    
    // Style
    [self styleContainer:self.centerPanelContainer];
    [self stylePanel:self.centerPanel.view];
    
    // Layout
    [self positionCenterContainerForState:self.state animated:NO];
    
    // Gestures
    [self _addTapGestureToView:self.centerPanelContainer];
    [self addPanGestureToView:self.centerPanelContainer];
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
    self.leftPanelContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.rightPanelContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
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
            centerFrame.origin.x = kSidePanelWidth;
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

//
// setCenterPanel:
//
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


//
// setLeftPanel:
//
- (void)setLeftPanel:(UIViewController *)leftPanel {
    if (leftPanel != _leftPanel) {
        [self _removeChildVC:_leftPanel];
        _leftPanel = leftPanel;
        if (_leftPanel) {
            [self _addChildVC:leftPanel intoView:self.leftPanelContainer];
        }
    }
}

//
// setRightPanel:
//
- (void)setRightPanel:(UIViewController *)rightPanel {
    if (rightPanel != _rightPanel) {
        [self _removeChildVC:_rightPanel];
        _rightPanel = rightPanel;
        if (_rightPanel) {
            [self _addChildVC:rightPanel intoView:self.rightPanelContainer];
        }
    }
}


#pragma mark - Style

//
// styleContainer:
//
- (void)styleContainer:(UIView *)container
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:container.bounds cornerRadius:0.0f];
    container.layer.shadowPath = shadowPath.CGPath;
    container.layer.shadowColor = [UIColor blackColor].CGColor;
    container.layer.shadowRadius = 10.0f;
    container.layer.shadowOpacity = 0.75f;
    container.clipsToBounds = NO;
}

//
// stylePanel:
//
- (void)stylePanel:(UIView *)panel
{
    panel.layer.cornerRadius = 6.0f;
    panel.clipsToBounds = YES;
}


#pragma mark - Private

//
// _removeChildVC:
//
- (void)_removeChildVC:(UIViewController *)vc
{
    [vc willMoveToParentViewController:nil];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}

//
// _addChildVC: intoView:
//
- (void)_addChildVC:(UIViewController *)vc intoView:(UIView *)targetView
{
    [self addChildViewController:vc];
    vc.view.frame = targetView.bounds;
    [targetView addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}


#pragma mark - Gesture Recognizer Delegate

//
// gestureRecognizerShouldBegin:
//
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

//
// addPanGestureToView:
//
- (void)addPanGestureToView:(UIView *)view
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [view addGestureRecognizer:panGesture];
}

//
// handlePan:
//
- (void)handlePan:(UIPanGestureRecognizer *)panRecognizer
{
    // If pan beginning, record initial state
    if ( UIGestureRecognizerStateBegan == panRecognizer.state ) {        
        self.initialCenterPanelOrigin = self.centerPanelContainer.frame.origin;
    }

    // Get the total movement since start of gesture
    CGPoint point = [panRecognizer translationInView:self.centerPanelContainer];
    CGFloat xTotalMovement = point.x;
    
    // Compute constraints
    CGFloat maxOriginX = kSidePanelWidth;
    CGFloat minOriginX = CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.centerPanelContainer.frame) - kSidePanelWidth;
    
    CGFloat xMovementSinceStarted = xTotalMovement;
    CGFloat newOriginX = self.initialCenterPanelOrigin.x + xMovementSinceStarted;
    
    // Constraints
    // Let's compute how far the drag is beyond the sidebar size. Then, we'll multiple that distance
    // by a spring constant to give an elasticity to the drag that's beyond the boundary
    CGFloat springValue = 0.05f;
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

    
    // Check for ending states.
    // If just ended, compute new target position and animate there
    if ( UIGestureRecognizerStateEnded == panRecognizer.state ) {
        [self positionCenterContainerForState:[self targetStateForCenterPanel] animated:YES];
    }
    // If cancelled, reset position to original state
    else if (UIGestureRecognizerStateCancelled == panRecognizer.state ) {
        [self positionCenterContainerForState:self.state animated:YES];
    }
}

#pragma mark - Manual Touch Handling

/*
//
// touchesBegan: withEvent:
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"TOUCHES BEGAN in CONTAINER");
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
        CGFloat springValue = 0.05f;
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
*/

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


@end
