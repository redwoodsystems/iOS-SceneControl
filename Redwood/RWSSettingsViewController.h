//
//  RWSSettingsViewController.h
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "RWSSettings.h"

@interface RWSSettingsViewController : UITableViewController <UITextFieldDelegate>
{
    NSArray *tableArray;
    UIView *myHeaderView;
    
    UITableViewCell *cell0;
    UITableViewCell *cell1;
    
    UITextField *loginId; 
    UITextField *password;
    
    RWSSettings *settings;
    
    BOOL hasClusterChanged;
    
}

@property(nonatomic, strong) NSArray *tableArray;
@property (nonatomic, strong) IBOutlet UIView *myHeaderView;

@property (nonatomic, strong) IBOutlet UITableViewCell *cell0;
@property (nonatomic, strong) IBOutlet UITableViewCell *cell1;

@property (nonatomic, strong) IBOutlet UITextField *loginId;
@property (nonatomic, strong) IBOutlet UITextField *password;


@end
