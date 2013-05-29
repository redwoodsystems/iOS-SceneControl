//
//  RWSLocationsViewController.h
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface RWSLocationsViewController : UITableViewController
{

}
@property (nonatomic) BOOL isPicker;

- (IBAction)addNewItem:(id)sender;

- (id)initAsPicker;

@end
