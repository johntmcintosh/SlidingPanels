//
//  CenterVC.m
//  SlidingPanels
//
//  Created by John Mcintosh  on 1/30/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import "CenterVC.h"

@interface CenterVC ()

@end

@implementation CenterVC

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

//    CGFloat red = (CGFloat)arc4random() / 0x100000000;
//    CGFloat green = (CGFloat)arc4random() / 0x100000000;
//    CGFloat blue = (CGFloat)arc4random() / 0x100000000;
//    self.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
    self.view.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    
    UILabel *label  = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:20.0f];
    label.text = @"Center Panel";
    [label sizeToFit];
    label.center = CGPointMake(floorf(self.view.bounds.size.width/2.0f), floorf((self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height)/2.0f));
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//
// touchesBegan: withEvent:
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"TOUCHES BEGAN in VC");
    [super touchesBegan:touches withEvent:event];
}


@end
