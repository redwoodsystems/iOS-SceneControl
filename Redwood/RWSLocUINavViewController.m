//
//  RWSLocUINavViewController.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//

#import "RWSLocUINavViewController.h"
#import "RWSUtil.h"
#import "RWSDebug.h"

@interface RWSLocUINavViewController ()

@end

@implementation RWSLocUINavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //Set the tab bar item title and image
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Locations"];
        //UIImage *im = [UIImage imageNamed:@"Time.png"];
        UIImage *im = [UIImage imageNamed:@"Location_s1.png"];
        [tbi setImage:im];

    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return ([RWSUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}

@end
