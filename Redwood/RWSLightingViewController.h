//
//  RWSLightingViewController.h
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "RWSLocationItem.h"
#import "RWSChannel.h"

@interface RWSLightingViewController : UITableViewController
{
    UIView *myHeaderView;

    UITableView *myTableView;

    UITableViewCell *cell0;
    
    RWSChannel *channel;
    
    NSInteger prev_idx;
    
}

@property (nonatomic, strong) RWSLocationItem *currentLocation;

@property(nonatomic, strong) NSMutableArray *tableArray;
@property (nonatomic, strong) IBOutlet UIView *myHeaderView;
@property (nonatomic, strong) IBOutlet UITableViewCell *cell0;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;

@property (nonatomic, weak) IBOutlet UIImageView *refreshIconView;
@property (nonatomic, weak) IBOutlet UIButton *refreshButton;
@property (nonatomic, weak) IBOutlet UIButton *locationName;

- (IBAction)testButtonClick:(id)sender;
- (IBAction)refreshButtonClick:(id)sender;
- (IBAction)locationButtonClick:(id)sender;


@end
