#import "Kiwi.h"
#import "UBSlidingPanelController.h"


SPEC_BEGIN(UBSlidingPanelControllerSpec)




describe(@"UBSlidingPanelController", ^{
   
    context(@"a state the component is in", ^{

        __block UBSlidingPanelController *vc = nil;
        
        beforeAll(^{ // Occurs once
        });
        
        afterAll(^{ // Occurs once
        });
        
        beforeEach(^{ // Occurs before each enclosed "it"
            vc = [[UBSlidingPanelController alloc] init];
        });
        
        afterEach(^{ // Occurs after each enclosed "it"
        });
        
        it(@"should be initialized to left panel state", ^{
            [[@(vc.state) should] equal:@(UBSlidingPanelLeftVisible)];
        });
        
        
    });
    
});




SPEC_END