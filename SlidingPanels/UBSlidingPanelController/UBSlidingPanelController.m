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
@end

static CGFloat kCenterPanelWidth = 768.0f;
static CGFloat kSidePanelWidth = 1024.0f - 768.0f;
static CGFloat kSidePanelPadding = 50.0f;


@implementation UBSlidingPanelController

//
// init
//
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
    
    // Accessibility
    self.centerPanelContainer.accessibilityLabel = @"Center Panel";
    
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
// willRotateToInterfaceOrientation: duration:
//
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Update panel position based on where rotation is going
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ) {
        UBSlidingPanelState targetState = self.state;
        if ( UBSlidingPanelCenterOnly == self.state ) {
            targetState = UBSlidingPanelLeftVisible;
        }
        _state = targetState;
    }

}

//
// willAnimateRotationToInterfaceOrientation: duration:
//
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self positionCenterContainerForState:self.state interfaceOrientation:toInterfaceOrientation animated:YES];
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
    
    NSLog(@"state: %i", state);
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
    [self positionCenterContainerForState:state interfaceOrientation:self.interfaceOrientation animated:animated];
}

//
// positionCenterContainerForState: interfaceOrientation: animated:
//
- (void)positionCenterContainerForState:(UBSlidingPanelState)state interfaceOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated
{
    CGRect centerFrame = self.centerPanelContainer.frame;
    
    switch (state) {
        case UBSlidingPanelCenterOnly:
            // CenterOnly will also show left panel in landscape
            centerFrame.origin.x = (UIInterfaceOrientationIsLandscape(orientation)) ? kSidePanelWidth : 0.0f;
            break;
        case UBSlidingPanelLeftVisible:
            centerFrame.origin.x = kSidePanelWidth;
            break;
        case UBSlidingPanelRightVisible:
            centerFrame.origin.x = (UIInterfaceOrientationIsLandscape(orientation)) ? 0.0f : -kSidePanelWidth;
            break;
        default:
            break;
    }

    // viewWillAppear/Disappear notifications to children
    
    // Move the center panel
    CGFloat duration = (animated) ? 0.25 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.centerPanelContainer.frame = centerFrame;
    } completion:^(BOOL finished) {
        // viewDidAppear/Disappear notifications to children
        
    }];    
}


//
// nextToggleState
//
- (UBSlidingPanelState)nextToggleState
{
    UBSlidingPanelState nextState;
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    switch (self.state) {
        case UBSlidingPanelCenterOnly:
            nextState = UBSlidingPanelLeftVisible;
            break;
        case UBSlidingPanelLeftVisible:
            nextState = (UIInterfaceOrientationIsPortrait(orientation)) ? UBSlidingPanelCenterOnly : UBSlidingPanelRightVisible;
            break;
        case UBSlidingPanelRightVisible:
            nextState = (UIInterfaceOrientationIsPortrait(orientation)) ? UBSlidingPanelCenterOnly : UBSlidingPanelLeftVisible;
            break;
        default:
            nextState = UBSlidingPanelCenterOnly;
            break;
    }
    return nextState;
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



#pragma mark - Panel Buttons

//
// addTogglePanelsButton
//
- (void)addTogglePanelsButton
{
    if (self.centerPanel) {
        UIViewController *vcWithButton = self.centerPanel;
        
        // If navigation controller, go find the root VC
        if ([vcWithButton isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navC = (UINavigationController *)vcWithButton;
            if ([navC.viewControllers count] > 0) {
                vcWithButton = [navC.viewControllers objectAtIndex:0];
            }
        }
        if (!vcWithButton.navigationItem.leftBarButtonItem) {
            vcWithButton.navigationItem.leftBarButtonItem = [self toggleBarButton];
        }
    }
}

//
// toggleBarButton
//
- (UIBarButtonItem *)toggleBarButton
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[[self class] defaultImage] style:UIBarButtonItemStylePlain target:self action:@selector(toggleCenterPanel:)];
    barButtonItem.accessibilityLabel = @"Toggle Center Panel";
    return barButtonItem;
}

//
// defaultImage
// github.com/gotosleep/JASidePanels
//
+ (UIImage *)defaultImage
{
	static UIImage *defaultImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 13.f), NO, 0.0f);
		
		[[UIColor blackColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 5, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 10, 20, 1)] fill];
		
		[[UIColor whiteColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 1, 20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 6,  20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 11, 20, 2)] fill];
		
		defaultImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        
	});
    return defaultImage;
}

//
// toggleCenterPanel:
//
- (IBAction)toggleCenterPanel:(id)sender
{
    self.state = [self nextToggleState];
}


#pragma mark - Panels

//
// setCenterPanel:
//
- (void)setCenterPanel:(UIViewController *)centerPanel {

    if (centerPanel != _centerPanel) {
        
        // Remove
        [_centerPanel removeObserver:self forKeyPath:@"view"];
        [_centerPanel removeObserver:self forKeyPath:@"viewControllers"];
        _centerPanel = centerPanel;

        // Add
        [self _removeChildVC:_centerPanel];
        if (centerPanel) {
            [self _addChildVC:centerPanel intoView:self.centerPanelContainer];
        }
        
        // Bar Button
        [self addTogglePanelsButton];
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
    // Tap to bring panel back to center
    // We only want to fire this recognizer if we're in portrait with left or right visible
    if ( [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] ) {
        if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) {
            if ( (UBSlidingPanelLeftVisible == self.state) ||
                 (UBSlidingPanelRightVisible == self.state) ) {
                return YES;
            }
        }
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
    self.state = [self nextToggleState];
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
        self.state = [self targetStateForCenterPanel];
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


@end
