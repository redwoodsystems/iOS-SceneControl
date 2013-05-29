//
//  RWSLightingNavViewController.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import "RWSLightingNavViewController.h"
#import "RWSUtil.h"

@interface RWSLightingNavViewController ()

@end

@implementation RWSLightingNavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //Set the tab bar item title and image
        
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Lighting"];
        //UIImage *im = [UIImage imageNamed:@"Hypno.png"];
        UIImage *im = [UIImage imageNamed:@"Lighting_s1.png"];
        [tbi setImage:im];
        
        
        //[self setNavigationBarHidden:YES];
        
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return ([RWSUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}

@end
