//
//  RWSLocSrchViewController.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//

#import "RWSLocSrchViewController.h"
#import "RWSLocationItemStore.h"
#import "RWSLocationItem.h"
#import "RWSChannel.h"
#import "RWSUtil.h"
#import "RWSDebug.h"

@interface RWSLocSrchViewController ()

@end

@implementation RWSLocSrchViewController

@synthesize filteredListContent;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        DLog(@"initWithStyle");                
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        DLog(@"initWithNibName");                
    }    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DLog(@"ViewDidLoad");
    filteredListContent = [NSMutableArray arrayWithCapacity:50];

    self.searchDisplayController.searchBar.scopeButtonTitles = nil;
    
    [self fetchAllLocations];
    
    [[self tableView] reloadData];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    DLog(@"ViewDidLoad");
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    filteredListContent = nil;
    channel = nil;
}


- (void) addNewItem:(id)sender
{
    RWSLocationItem *newItem = [[RWSLocationItemStore defaultStore] createItem];
    int lastRow = [[[RWSLocationItemStore defaultStore] allItems] indexOfObject:newItem];
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip]
                            withRowAnimation:UITableViewRowAnimationTop];
    
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView){   
        int cnt = [filteredListContent count];
        DLog(@"filtered row count %d",cnt);
        return [filteredListContent count];        
    }else {
        return [[channel items] count];
    }
    //show empty table if there is no match. Thus default table will be empty.
    
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
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        RWSLocationItem *p = [filteredListContent objectAtIndex:indexPath.row];  
        [[cell textLabel] setText:[p locationName]];
    } else {
        RWSLocationItem *p = [[channel items] objectAtIndex:indexPath.row];  
        [[cell textLabel] setText:[p locationName]];        
    }
    
    return cell;
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[filteredListContent removeAllObjects]; // First clear the filtered array.
    
    //initiate a call to the api to get matching locations
    DLog(@"filterContentForSearchText: %@",searchText);
    
    for (RWSLocationItem *location in [channel items]){        
        NSComparisonResult result = [[location locationName] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame)
        {
            [self.filteredListContent addObject:location];
        }
        
    }
    	
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
     //Would do this only if we want to search on every char entered in search bar
    [self filterContentForSearchText:searchString scope:nil];
    
    return YES;
        
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    DLog(@"Search button clicked");
    
    NSString *searchString = [searchBar text];
    
    [self filterContentForSearchText:searchString scope:nil];

    /*
    int cnt = [filteredListContent count];        
    if (cnt >0){
         DLog(@"Reloading search table");
        UITableView *table = self.searchDisplayController.searchResultsTableView;
        [table reloadData];
    } 
     */
    
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //when row is selected in search results, add new row to the store.
    //this is specific to the use case for finding a new location from the server and not already
    // present in the device store
    //need to make sure that location is not already present to prevent duplicates
    //alternatively we can call on a method on the rootviewcontroller (locations to add the item to the store
    
    RWSLocationItem *p = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        p = [filteredListContent objectAtIndex:indexPath.row];
    } else {
        p = [[channel items] objectAtIndex:indexPath.row];
    }
    
    
    //add or replace location
    //TODO: get a full location object by calling the API for given location id
    
    [[RWSLocationItemStore defaultStore] addItem:p];
    
    DLog(@"adding new item to store..count %d",
                        [[[RWSLocationItemStore defaultStore] allItems] count] );
    
    //dismiss the loc search controller
    [[self navigationController] popViewControllerAnimated:YES];
}


//fetch locations from api
- (void)fetchAllLocations
{
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] 
                                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [[self navigationItem] setTitleView:aiView];
    [aiView startAnimating];
    
    
    void (^completionBlock)(RWSChannel *obj, NSError *err) = ^(RWSChannel *obj, NSError *err) {
        // When the request completes, this block will be called.
        
        if(!err) {
            // If everything went ok, grab the channel object and
            // reload the table.
            DLog(@"In completion block");
            channel = obj;
            
            /*
            for (int i=0; i < [[channel items] count]; i++){
                [filteredListContent addObject:[[channel items] objectAtIndex:i]];
            } */
            //filteredListContent = [channel items];
            
            [[self tableView] reloadData];
            
            [aiView stopAnimating];
            
            DLog(@"Reloading search table");
            //UITableView *table = self.searchDisplayController.searchResultsTableView;
            //[table reloadData];
            
            if ([[channel items] count] == 0){
                // Create and show an alert view with this error displayed
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"No locations found on this cluster"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];            
            }
            
        } else {
            
            [aiView stopAnimating];
            
            // If things went bad, show an alert view
            NSString *errorString = [NSString stringWithFormat:@"Fetch locations failed: %@", 
                                     [err localizedDescription]];
            
            DLog(@"In completion block..error %@",errorString );
            
            // Create and show an alert view with this error displayed
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:errorString
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
    };
    
    // Initiate the request and call the completion block above on completion
    //with an RWSChannel
    [[RWSLocationItemStore defaultStore] fetchAllLocationsWithCompletion:completionBlock];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    return ([RWSUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}



@end
