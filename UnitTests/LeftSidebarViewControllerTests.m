#import "Kiwi.h"
#import "LeftSidebarViewController.h"


@interface LeftSidebarViewController ()
// Properties
@property(nonatomic, strong) UITableView *tableView;

// Methods
- (void)createTableViewAndAddToView;
- (void)setTableHeaderView;
@end



SPEC_BEGIN(LeftSidebarViewControllerTests)

//
// Left Panel
//
describe(@"Test TableView setup" , ^{
    
    // Vars
    __block LeftSidebarViewController *vc;
    
    // Setup
    beforeEach(^{
        vc = [[LeftSidebarViewController alloc] init];
        [vc createTableViewAndAddToView];
    });
    
    // Tests
    it(@"should create table view", ^{
        [[vc.tableView should] beNonNil];
    });
    
    it(@"should have header view set", ^{
        [vc setTableHeaderView];
        [[vc.tableView.tableHeaderView should] beNonNil];
    });
        
    it(@"Table should have 3 sections", ^{
        NSInteger numSections = [vc numberOfSectionsInTableView:vc.tableView];
        [[@(numSections) should] equal:@(3)];
    });
});


describe(@"Test Accounts section", ^{

    // Vars
    __block LeftSidebarViewController *vc;
    NSInteger section = 0;
    
    // Setup
    beforeEach(^{
        vc = [[LeftSidebarViewController alloc] init];
        [vc createTableViewAndAddToView];
    });

    it(@"Should have correct section title", ^{
        NSString *title = [vc tableView:vc.tableView titleForHeaderInSection:section];
        [[title should] equal:@"Accounts"];
    });

    // TODO: Dependent on datasource
//    it(@"Should have correct number of rows", ^{
//        NSInteger numRows = [vc tableView:vc.tableView numberOfRowsInSection:section];
//        [[@(numSections) should] equal:@(0)];
//    });
    
});


describe(@"Test Pending section", ^{
    
    // Vars
    __block LeftSidebarViewController *vc;
    NSInteger section = 1;
    
    // Setup
    beforeEach(^{
        vc = [[LeftSidebarViewController alloc] init];
        [vc createTableViewAndAddToView];
    });
    
    it(@"Should have correct section title", ^{
        NSString *title = [vc tableView:vc.tableView titleForHeaderInSection:section];
        [[title should] equal:@"Pending"];
    });
    
    it(@"Should have correct number of rows", ^{
        NSInteger numRows = [vc tableView:vc.tableView numberOfRowsInSection:section];
        [[@(numRows) should] equal:@(2)];
    });
    
});


SPEC_END