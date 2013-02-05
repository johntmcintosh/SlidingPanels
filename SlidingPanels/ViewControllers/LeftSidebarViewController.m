//
//  LeftSidebarViewController.m
//  SlidingPanels
//
//  Created by John Mcintosh  on 2/4/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import "LeftSidebarViewController.h"

@interface LeftSidebarViewController ()
// Properties
@property(nonatomic, strong) UITableView *tableView;

// Methods
- (void)createTableViewAndAddToView;
- (void)setTableHeaderView;
@end

// Sections
typedef enum {
    kTableSectionAccounts = 0,
    kTableSectionPending,
    kTableSectionSettings
} kTableSection;

// Rows
typedef enum {
    kPendingSectionRowPayments = 0,
    kPendingSectionRowTransfers
} kPendingSectionRow;


typedef enum {
    kSettingsSectionRowSettings = 0,
    kSettingsSectionRowHelp
} kSettingsSectionRow;


@implementation LeftSidebarViewController

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createTableViewAndAddToView];
    [self setTableHeaderView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark View Setup

- (void)createTableViewAndAddToView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)setTableHeaderView {
    [self.tableView setTableHeaderView:[self instanceOfTableHeaderView]];
}

- (UIView *)instanceOfTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60.0f)];
    return headerView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( kTableSectionAccounts == section ) {
        return 0;
    }
    else if ( kTableSectionPending == section ) {
        return 2;
    }
    else if ( kTableSectionSettings == section ) {
        return 2;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ( kTableSectionAccounts == section ) {
        return @"Accounts";
    }
    else if ( kTableSectionPending == section ) {
        return @"Pending";
    }
    else if ( kTableSectionSettings == section ) {
        return @"Settings & Help";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ( kTableSectionAccounts == indexPath.section ) {
        
    }
    else if ( kTableSectionPending == indexPath.section ) {
        if ( kPendingSectionRowPayments == indexPath.row ) {
            cell.textLabel.text = @"Payments";
        }
        else if ( kPendingSectionRowTransfers == indexPath.row ) {
            cell.textLabel.text = @"Transfers";
        }
    }
    else if ( kTableSectionSettings == indexPath.section ) {
        if ( kSettingsSectionRowSettings == indexPath.row ) {
            cell.textLabel.text = @"Settings";
        }
        else if ( kSettingsSectionRowHelp == indexPath.row ) {
            cell.textLabel.text = @"Help";
        }
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
