//
//  ScrollVC.m
//  SlidingPanels
//
//  Created by John Mcintosh  on 1/31/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import "ScrollVC.h"

@interface ScrollVC ()

@end

@implementation ScrollVC

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
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];

    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    sv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:sv];
    sv.contentSize = CGSizeMake(CGRectGetWidth(sv.frame), CGRectGetHeight(sv.frame)*2);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
