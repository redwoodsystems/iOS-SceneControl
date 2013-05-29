//
//  RWSLocationsViewController.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import "RWSLocationsViewController.h"
#import "RWSLocationItem.h"
#import "RWSLocationItemStore.h"
#import "RWSLocSrchViewController.h"
#import "RWSLightingViewController.h"
#import "RWSSettingsStore.h"
#import "RWSUtil.h"
#import "RWSDebug.h"

@interface RWSLocationsViewController ()

@end

@implementation RWSLocationsViewController
@synthesize isPicker;

- (id) init
{
    //call the designated superclasses
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        [self setIsPicker: NO];
        
        //Set the tab bar item title and image
        //UITabBarItem *tbi = [self tabBarItem];
        //[tbi setTitle:@"Locations"];
        
        UINavigationItem *n = [self navigationItem];
        [n setTitle:@"Locations"];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        
        [[self navigationItem] setRightBarButtonItem:bbi];
        
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
                
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (id)initAsPicker
{
    //call the designated superclasses
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self setIsPicker: YES];
        [[self navigationController] setNavigationBarHidden:NO];
    }

    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int cnt = [[[RWSLocationItemStore defaultStore]allItems]count];
    DLog(@"!!!row count %d",cnt);
    return [[[RWSLocationItemStore defaultStore]allItems]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // If there is no reusable cell of this type, create a new one
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"UITableViewCell"];
    }
    
    //Set the text on the cell with the location name
    RWSLocationItem *p = [[[RWSLocationItemStore defaultStore]allItems] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[p locationName]];
    return cell;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (isPicker){
        [[self navigationController] setNavigationBarHidden:NO];
        [[self navigationItem] setLeftBarButtonItem:nil];
        [[self navigationItem] setRightBarButtonItem:nil];
    }
    
    [[self tableView] reloadData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[[RWSSettingsStore defaultStore] settings] shouldRefreshLocations]){
        DLog(@"Cluster name or password has changed.. deleting stored locations");           
        [[RWSLocationItemStore defaultStore] removeAllItems];
        BOOL success = [[RWSLocationItemStore defaultStore] saveChanges];      
        
        if (success){
            DLog(@"Saved locations to file");
        } else {
            DLog(@"Could not save locations");
        }
        
        [[[RWSSettingsStore defaultStore] settings] setLastPickedLocationId:0];
        [[[RWSSettingsStore defaultStore] settings] setShouldRefreshLocations:NO];
        
        success = [[RWSSettingsStore defaultStore] saveChanges];
        
        if (success){
            DLog(@"Saved settings to file %@",[[RWSSettingsStore defaultStore] settings] );
        } else {
            DLog(@"Could not save settings");
        }
    }
    
    [[self tableView] reloadData];
}


- (void) addNewItem:(id)sender
{

    
    //RWSLocationItem *newItem = [[RWSLocationItemStore defaultStore] createItem];
    //int lastRow = [[[RWSLocationItemStore defaultStore] allItems] indexOfObject:newItem];
    
    //NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    //[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip]
    //                        withRowAnimation:UITableViewRowAnimationTop];    

    RWSLocSrchViewController *lsvc = [[RWSLocSrchViewController alloc] initWithNibName:@"RWSLocSrchViewController" bundle:nil];
    
    [[self navigationController] pushViewController:lsvc animated:YES];
    
    
}

//required for deleting row
- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        RWSLocationItemStore *ps = [RWSLocationItemStore defaultStore];
        NSArray *items = [ps allItems];
        RWSLocationItem *p = [items objectAtIndex:[indexPath row]];
        [ps removeItem:p];
        
        // We also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void)tableView:(UITableView *)tableView 
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
      toIndexPath:(NSIndexPath *)toIndexPath 
{
    [[RWSLocationItemStore defaultStore] moveItemAtIndex:[fromIndexPath row] toIndex:[toIndexPath row]];

}

- (void) viewWillAppear:(BOOL)animated
{
    //reload data when view appears from search
    [super viewWillAppear:animated];
    
    
    [[self tableView] reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //this method is used when controller is used in picker mode
    if (isPicker)
	{
        RWSLocationItem *p = [[[RWSLocationItemStore defaultStore] allItems] objectAtIndex:indexPath.row];
        DLog(@"user picked %@",[p locationName]);
        
        //get back view controller
        NSArray *controllers = [[self navigationController] viewControllers];
        RWSLightingViewController *back = [controllers objectAtIndex:[controllers count]-2];
        
        if ([back respondsToSelector:@selector(setCurrentLocation:)]){
            DLog(@"set location on back");
            [back setCurrentLocation:p];
        }

        //dismiss the loc search controller
        [[self navigationController] popViewControllerAnimated:YES];
    }        
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
   return ([RWSUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}


@end
