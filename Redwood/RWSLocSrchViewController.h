//
//  RWSLocSrchViewController.h
//  Table4
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWSChannel.h"
#import "RWSDebug.h"

@interface RWSLocSrchViewController : UITableViewController
{
    
	NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
    RWSChannel *channel;
    
}

@property (nonatomic) NSMutableArray *filteredListContent;

- (IBAction)addNewItem:(id)sender;

@end
