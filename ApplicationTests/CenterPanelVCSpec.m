#import "Kiwi.h"

// VCs
#import "LeftVC.h"
#import "RightVC.h"
#import "CenterVC.h"


@interface CenterVC ()
- (void)addMainButtonToMainView;
@end


SPEC_BEGIN(PanelsSpec)

//
// Left Panel
//
describe(@"Test left panel setup" , ^{

    // Vars
    __block LeftVC *vc;
    
    // Setup
    beforeEach(^{
         vc = [[LeftVC alloc] init];
    });
    
    // Tests
    it(@"should have gray background color", ^{
        [[vc.view.backgroundColor should] equal:[UIColor grayColor]];
        // This passes, but I don't know why. The value gets set in viewDidLoad
        // and I'm only calling init. At what point can I know that viewDidLoad
        // has been called?
    });
    
});


//
// Right Panel
//
describe(@"Test right panel setup", ^{
    // Vars
    __block RightVC *vc;
    
    // Setup
    beforeEach(^{
        vc = [[RightVC alloc] init];
    });
    
    // Tests
    it(@"should have gray background color", ^{
        [[vc.view.backgroundColor should] equal:[UIColor darkGrayColor]];
    });    
});


//
// Center Panel
//
describe(@"Test center panel setup" , ^{
    
    // Vars
    __block CenterVC *vc;
    
    // Setup
    beforeEach(^{
        vc = [[CenterVC alloc] init];
        [vc addMainButtonToMainView];
    });
    
    // Tests
    it(@"should have correct background color", ^{
        [[vc.view.backgroundColor should] equal:[UIColor colorWithWhite:0.7 alpha:1.0]];
    });
    
    it(@"Main button should be set", ^{
        [vc.mainButton shouldNotBeNil];
    });

    it(@"Main button have action set", ^{
        [[[vc.mainButton actionsForTarget:vc forControlEvent:UIControlEventTouchUpInside] should] haveCountOfAtLeast:1];
    });
    
});



SPEC_END