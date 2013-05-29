//
//  RWSUtil.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//

#import "RWSUtil.h"

@implementation RWSUtil

+ (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return (interfaceOrientation == UIInterfaceOrientationPortrait || 
                interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);        
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

@end
