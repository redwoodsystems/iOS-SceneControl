//
//  RWSLightingViewController.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import "RWSLightingViewController.h"
#import "RWSLocationsViewController.h"
#import "RWSSettingsStore.h"
#import "RWSLocationItemStore.h"
#import "RWSLocationItem.h"
#import "RWSSceneItem.h"
#import "RWSUtil.h"
#import "RWSDebug.h"

@interface RWSLightingViewController ()

@end

@implementation RWSLightingViewController

@synthesize tableArray, myHeaderView, myTableView;
@synthesize cell0;
@synthesize refreshIconView, refreshButton, locationName;
@synthesize currentLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //UITabBarItem *tbi = [self tabBarItem];
        //[tbi setTitle:@"Lighting"];
        
        UINavigationItem *n = [self navigationItem];
        [n setTitle:@"Lighting"];
        
        [self setTableArray:[[NSMutableArray alloc] initWithCapacity:30]];
                        
    }
    return self;
}


- (void)setCurrentLocation:(RWSLocationItem *)currLoc{
    currentLocation = currLoc;
    [[[RWSSettingsStore defaultStore] settings] setLastPickedLocationId:[currLoc locationId]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // setup our table data
    //self.tableArray = [NSMutableArray arrayWithObjects:@"Scene 1", @"Scene 2", @"Scene 3", nil];
    
    // set up the table's header view based on our UIView 'myHeaderView' outlet
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.myHeaderView.frame.size.height);
	self.myHeaderView.backgroundColor = [UIColor clearColor];
	self.myHeaderView.frame = newFrame;
	self.tableView.tableHeaderView = self.myHeaderView;	// note this will override UITableView's 'sectionHeaderHeight' property
        
    //initialize other UI elements:
    if (!currentLocation){
        //load current location from settings file if present
        int locId = [[[RWSSettingsStore defaultStore] settings] lastPickedLocationId];
        if (locId >0){
            for (int i=0; i<[[[RWSLocationItemStore defaultStore]allItems]count]; i++){
                RWSLocationItem *loc = [[[RWSLocationItemStore defaultStore]allItems] objectAtIndex:i];
                if (locId == [loc locationId]){
                    currentLocation = loc;
                }
            }
        }
    }
    
    
    if (currentLocation){
        [locationName setTitle:[currentLocation locationName] forState:UIControlStateNormal];
    } else {
        [locationName setTitle:@"" forState:UIControlStateNormal];
    }
        
    [[self navigationController] setNavigationBarHidden:YES];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES];
    
    DLog(@"currentLocation = %@", [currentLocation locationName]);
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
        
        //Also clear current location
        currentLocation = NULL;
        [locationName setTitle:@"" forState:UIControlStateNormal];
    }
    
    //check if currentLocation still exists in the location list. Else clear it.
    if (currentLocation){
        BOOL locExists = NO;
        for (int i=0; i<[[[RWSLocationItemStore defaultStore]allItems]count]; i++){
            RWSLocationItem *loc = [[[RWSLocationItemStore defaultStore]allItems] objectAtIndex:i];
            if ([currentLocation locationId] == [loc locationId]){
                locExists = YES;
                break;
            }
        }
        if (!locExists){
            currentLocation = NULL;
            [locationName setTitle:@"" forState:UIControlStateNormal];
        }        
    }
    if (currentLocation){
        [self loadScenes];
    }else {
        [tableArray removeAllObjects];
        [[self tableView] reloadData];
    }

    //[[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0) {
        return 1;
    } else {
        return [tableArray count];
    }            
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //DLog(@"section %d row %d", [indexPath section], [indexPath row]);
    //Highlight color - Pantone291 (#A4D7F4)
    UIColor *highlightColor= [UIColor colorWithRed:(164.0/255.0) green:(215.0/255.0) blue:(244.0/255.0) alpha:1];
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == 0) {
        if (row ==0) { 
            if (currentLocation){
                [locationName setTitle:[currentLocation locationName] forState:UIControlStateNormal];
            }
            return cell0;
        }       
    } else {
        
        static NSString *kCellID = @"cellID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        //cell.textLabel.text = [tableArray objectAtIndex:[indexPath row]];
        RWSSceneItem *sc = [tableArray objectAtIndex:[indexPath row]];
        cell.textLabel.text = [sc sceneName];
        if ([sc isActive]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [cell setBackgroundColor:highlightColor];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
        
        return cell;
    }
    
    //something not right
    return nil;
}


- (IBAction)testButtonClick:(id)sender
{
    DLog(@"Apply Button pressed");
}

- (IBAction)refreshButtonClick:(id)sender
{
    DLog(@"Refresh button clicked");
    [self loadScenes];
}

- (IBAction)locationButtonClick:(id)sender
{
    DLog(@"Location Button pressed");

    RWSLocationsViewController *lvc = [[RWSLocationsViewController alloc] initAsPicker];
    [[self navigationController] pushViewController:lvc animated:YES];
    
}

- (UIActivityIndicatorView *) createActivityIndicatorView
{
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [aiView setFrame:CGRectMake(self.view.bounds.size.width / 2.0f - aiView.frame.size.width /2.0f, self.view.bounds.size.height / 2.0f - aiView.frame.size.height /2.0f, aiView.frame.size.width, aiView.frame.size.height)]; 
    [aiView setColor:[UIColor grayColor]];
    [[self view] addSubview:aiView]; 
    
    return aiView;    
}


- (void)loadScenes
{
    DLog(@"loadScenes...location_id=%d",[currentLocation locationId]);
    if (!currentLocation){
        [tableArray removeAllObjects];
        return;
    }
    
    //Show activity progress indicator
    UIActivityIndicatorView *aiView = [self createActivityIndicatorView];
    [[self view] setUserInteractionEnabled:NO];
    [aiView startAnimating];
    
    
    void (^completionBlock)(RWSChannel *obj, NSError *err) = ^(RWSChannel *obj, NSError *err) {
        // When the request completes, this block will be called.

        [aiView stopAnimating];
        [aiView removeFromSuperview];
        [[self view] setUserInteractionEnabled:YES];

        if(!err) {
            // If everything went ok, grab the channel object and
            // reload the table.
            DLog(@"In completion block of loadScenes");
            
            channel = obj;
            
            //loop on scenes (if present) and load tableArray
            //also initialize other UI elements dependent on location
            
            [self populateTableFromChannel];
            
            if ([tableArray count] == 0){
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"No scenes setup for this location"
                                                           delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                [av show];  
            }

            DLog(@"Reloading table");
            [[self tableView] reloadData];
        } else {
            
            // If things went bad, show an alert view
            NSString *errorString = [NSString stringWithFormat:@"Fetch Scenes failed: %@", 
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
    [[RWSLocationItemStore defaultStore] fetchLocation:[currentLocation locationId] withCompletion:completionBlock];

}

- (void) populateTableFromChannel
{
    if ([[channel items] count] == 0){
        return;
    }
    
    RWSLocationItem *loc = [[channel items] objectAtIndex:0];
    
    NSMutableArray *scenes = [NSMutableArray arrayWithCapacity:30];
    [scenes addObjectsFromArray:[loc scenes]];
    if ([scenes count] >0) {
        
        //sort the array based on scene order.
        [scenes sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            int ord1 = [(RWSSceneItem *)obj1 order];
            int ord2 = [(RWSSceneItem *)obj2 order];
            
            if (ord1 > ord2){
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (ord1 < ord2){
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;        
        }];
        
        
    }
        
    [tableArray removeAllObjects];
    [tableArray addObjectsFromArray:scenes];
    
    //Store updated object back to current location
    [self setCurrentLocation:loc];
        
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0){
        return;
    }
    
    //this method is used when controller is used in picker mode
    RWSSceneItem *p = [tableArray objectAtIndex:indexPath.row];
    //TODO: make sure this is truly a scene
    DLog(@"user picked %@",[p sceneName]);
    
    //deselect existing row
    NSIndexPath *prev_pth = nil;
    UITableViewCell *prev_cell = nil;
    //NSInteger prev_idx = -1;
    prev_idx = -1;
    UITableViewCell *cell = nil;
    
    //find previous selected row (if any) and clear selection
    for (int i=0; i < [[self tableArray] count]; i++){
        prev_pth = [NSIndexPath indexPathForRow:i inSection:1];
        prev_cell = [[self tableView] cellForRowAtIndexPath:prev_pth];
        if ([prev_cell accessoryType] == UITableViewCellAccessoryCheckmark){
            DLog(@"prev selected row = %d", i);
            prev_idx = (NSInteger) i;
            //clear earlier selection
            [prev_cell setAccessoryType:UITableViewCellAccessoryNone];
            [[self tableView] deselectRowAtIndexPath:prev_pth animated:YES];
            break;
        }
    }
    
    //current selection
    cell = [[self tableView] cellForRowAtIndexPath:indexPath];

    BOOL clearCurrentSelection = NO;
    if (prev_idx >= 0 && indexPath.row == prev_idx){                
        //Found earlier selection and is the same as current selection
        clearCurrentSelection = YES;
    }
    
    if (clearCurrentSelection) {
        //copy current active scene to revert later if needed
        NSString *lastActiveSceneName = [currentLocation activeSceneName];
        
        //create a dummy scene with empty name
        RWSSceneItem *sc = [[RWSSceneItem alloc] init];
        [sc setSceneName:@""];
        [sc setLocationId:[currentLocation locationId]];
        
        //call API to update scene status
        [self updateSceneStatus:sc];
        
        [currentLocation setLastActiveSceneName: lastActiveSceneName];            
        
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        RWSSceneItem *scene = [[self tableArray] objectAtIndex:[indexPath row]];
        
        //call API to update scene status for selected scene
        [self updateSceneStatus:scene];        

    }
    

}


- (void) updateSceneStatus: (RWSSceneItem *) scene
{
    DLog(@"updateSceneStatus...location_id=%d scene=%@",
          [currentLocation locationId], [scene sceneName]);
    if (!currentLocation || !scene){
        return;
    }

    //Call API to update scene status
    NSIndexPath *prev_pth = nil;
    
    //get prev selection path
    if (prev_idx >=0) {
        prev_pth = [NSIndexPath indexPathForRow:prev_idx inSection:1];
    }
    
    
    //Show activity progress indicator
    UIActivityIndicatorView *aiView = [self createActivityIndicatorView];
    [[self view] setUserInteractionEnabled:NO];
    [aiView startAnimating];
    
    
    void (^completionBlock)(RWSChannel *obj, NSError *err) = ^(RWSChannel *obj, NSError *err) {
        // When the request completes, this block will be called.
        
        UITableViewCell *prev_cell = nil;
        NSIndexPath *tmp_pth = nil;
        UITableViewCell *tmp_cell = nil;
        NSInteger tmp_idx = -1;

        [aiView stopAnimating];
        [aiView removeFromSuperview];
        [[self view] setUserInteractionEnabled:YES];
        
        if(!err) {
            // If everything went ok, grab the channel object and
            // reload the table.
            DLog(@"In completion block of updateSceneStatus");
            channel = obj;
            
            //check responseType from response json
            if ([channel postJsonResponse]){
                NSString *postResponseType = [[channel postJsonResponse] objectForKey:@"responseType"];
                if (postResponseType && [postResponseType isEqualToString:@"errorResponse"]){
                    DLog(@"Api returned error response %@ %@", 
                          [[channel postJsonResponse] objectForKey:@"responseErrorType"],
                          [[channel postJsonResponse] objectForKey:@"responseErrorDetail"]);
                    
                    NSString *errorString = 
                            [NSString stringWithFormat:@"Scene status update failed:  %@ : %@", 
                             [[channel postJsonResponse] objectForKey:@"responseErrorType"],
                             [[channel postJsonResponse] objectForKey:@"responseErrorDetail"] ];
                    
                    // Create and show an alert view with this error displayed
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:errorString
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                    [av show];                                
                    
                } else {
                    //update succeeded
                    DLog(@"Scene status successfully updated");
                    //make another request to load scenes if update was successful
                    //which internally will reload data
                    [self loadScenes];
                }
            }
            
            
        } else {
            
            // If things went bad, show an alert view
            NSString *errorString = [NSString stringWithFormat:@"Update scenes failed: %@", 
                                     [err localizedDescription]];
            
            DLog(@"In completion block..error %@",errorString );
            
            // Create and show an alert view with this error displayed
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:errorString
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];  
            
            //Clear current selection if exists
            for (int i=0; i < [[self tableArray] count]; i++){
                tmp_pth = [NSIndexPath indexPathForRow:i inSection:1];
                tmp_cell = [[self tableView] cellForRowAtIndexPath:tmp_pth];
                if ([tmp_cell accessoryType] == UITableViewCellAccessoryCheckmark){
                    DLog(@"clear curr selected row = %d", i);
                    tmp_idx = (NSInteger) i;
                    //clear earlier selection
                    [tmp_cell setAccessoryType:UITableViewCellAccessoryNone];
                    //[[self tableView] deselectRowAtIndexPath:tmp_pth animated:YES];
                    break;
                }
            }
            
            //Reset checkmark to original selection if exists
            if (prev_pth) {
                DLog(@"set checkmark back on idx = %d", prev_idx);
                prev_cell = [[self tableView] cellForRowAtIndexPath:prev_pth];
                [prev_cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                //[[self tableView] deselectRowAtIndexPath:prev_pth animated:YES];                        
            }

        }
    };
    
    // Initiate the request and call the completion block above on completion
    //with an RWSChannel    
    [[RWSLocationItemStore defaultStore] updateLocation:[currentLocation locationId] sceneName:[scene sceneName] withCompletion:completionBlock];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return ([RWSUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}


@end
