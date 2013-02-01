//
//  CenterVC.m
//  SlidingPanels
//
//  Created by John Mcintosh  on 1/30/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import "CenterVC.h"

@interface CenterVC ()
- (void)addMainButtonToMainView;
- (void)addCenterLabelToMainView;
@end

@implementation CenterVC

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    [self addCenterLabelToMainView];
    [self addMainButtonToMainView];
}


- (void)addMainButtonToMainView
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(10, 10, 100, 50);
    [btn setTitle:@"BTN" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.mainButton = btn;
}

- (void)addCenterLabelToMainView
{
    UILabel *label  = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:20.0f];
    label.text = @"Center Panel";
    [label sizeToFit];
    label.center = CGPointMake(floorf(self.view.bounds.size.width/2.0f),
                               floorf((self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height)/2.0f));
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:label];
}

- (IBAction)btnPressed:(id)sender
{
    CenterVC *vc = [[CenterVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
