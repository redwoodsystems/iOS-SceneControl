//
//  RWSSettingsViewController.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//

#import "RWSSettingsViewController.h"
#import "RWSSettings.h"
#import "RWSSettingsStore.h"
#import "RWSLocationItemStore.h"
#import "RWSUtil.h"
#import "RWSDebug.h"

@interface RWSSettingsViewController ()

@end

@implementation RWSSettingsViewController

@synthesize tableArray;
@synthesize myHeaderView;
@synthesize cell0,cell1;
@synthesize loginId, password;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Settings"];
        //UIImage *im = [UIImage imageNamed:@"Time.png"];
        UIImage *im = [UIImage imageNamed:@"Settings_s1.png"];
        [tbi setImage:im];

        
    }
    return self;
}

- (void)viewDidLoad
{
    DLog(@"viewdidload..%@", @"ok then");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // set up the table's header view based on our UIView 'myHeaderView' outlet
    
    // setup our table data
    self.tableArray = [NSArray arrayWithObjects:@"Scene 1", @"Scene 2", @"Scene 3", nil];
    
    CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.myHeaderView.frame.size.height);
	self.myHeaderView.backgroundColor = [UIColor clearColor];
	self.myHeaderView.frame = newFrame;
	self.tableView.tableHeaderView = self.myHeaderView;	// note this will override UITableView's 'sectionHeaderHeight' property
    
    //set initial values from stored settings
    [[self loginId] setText:[[[RWSSettingsStore defaultStore] settings] clusterName]];
    [[self password] setText:[[[RWSSettingsStore defaultStore] settings] password]]; 
    
    //initialize dirty flag
    hasClusterChanged = NO;
    
}

- (void)viewDidUnload
{
    DLog(@"in viewDidUnload..");
    DLog(@"cluster name: %@ password: %@",[[[RWSSettingsStore defaultStore] settings] clusterName],
          [[[RWSSettingsStore defaultStore] settings] password]);

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    if (hasClusterChanged) {
        [self saveSettings];
    }    

}

- (void) viewWillDisappear:(BOOL)animated
{
    DLog(@"in viewWillDisappear..");
    DLog(@"cluster name: %@ password: %@",[[[RWSSettingsStore defaultStore] settings] clusterName],
          [[[RWSSettingsStore defaultStore] settings] password]);
    
    [super viewDidDisappear:animated];
    
    [self saveSettings];

}


- (void) saveSettings
{
    BOOL success = NO;

    success = [[RWSSettingsStore defaultStore] saveChanges];
    
    if (success){
        DLog(@"Saved settings to file %@",[[RWSSettingsStore defaultStore] settings] );
    } else {
        DLog(@"Could not save settings");
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    return ([RWSUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0) {
        return 2;
    } else {
        return [tableArray count];
    } 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    DLog(@"section %d row %d", [indexPath section], [indexPath row]);

    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
        
    if (section == 0) {
        if (row ==0) { 
            [loginId setClearButtonMode:UITextFieldViewModeWhileEditing]; 
            [loginId setPlaceholder:@"clustername"];
            return cell0;
        } else {
            [password setClearButtonMode:UITextFieldViewModeWhileEditing];
            [password setPlaceholder:@"password"];
            
            return cell1;
        }        
    }    
    
    return NULL;
}

- (BOOL) hasValueChanged: (UITextField *)textField
{
    NSString *val;
    if ([textField tag] == 1){
        val = [[[RWSSettingsStore defaultStore] settings] clusterName]; 
    } else {
        val = [[[RWSSettingsStore defaultStore] settings] password]; 
    }
    
    if ([val isEqualToString:[textField text]]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    //do something
    DLog(@"In ..ShouldReturn: textfield: %d %@", [textField tag], [textField text]);
    
    if ([self hasValueChanged:textField]){
        if ([textField tag] == 1){
            [[[RWSSettingsStore defaultStore] settings] setClusterName:[textField text]];
        } else {        
            [[[RWSSettingsStore defaultStore] settings] setPassword:[textField text]];
        }        
        //hasClusterChanged = YES;
        [[[RWSSettingsStore defaultStore] settings] setShouldRefreshLocations:YES];        
    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    //do something
    DLog(@"In ..ShouldEndEditing: textfield: %d %@", [textField tag], [textField text]);
    
    if ([self hasValueChanged:textField]){
        if ([textField tag] == 1){
            [[[RWSSettingsStore defaultStore] settings] setClusterName:[textField text]];
        } else {        
            [[[RWSSettingsStore defaultStore] settings] setPassword:[textField text]];
        }        
        //hasClusterChanged = YES;
        [[[RWSSettingsStore defaultStore] settings] setShouldRefreshLocations:YES];        
    }
    [textField resignFirstResponder];
    return YES;
    
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    //do something
    DLog(@"In ..ShouldClear: textfield: %d %@", [textField tag], [textField text]);
    
    if ([textField tag] == 1){
        [[[RWSSettingsStore defaultStore] settings] setClusterName:@""];
    } else {        
        [[[RWSSettingsStore defaultStore] settings] setPassword:@""];
    }
    
    //hasClusterChanged = YES;
    [[[RWSSettingsStore defaultStore] settings] setShouldRefreshLocations:YES];
    
    [textField resignFirstResponder];
    return YES;
    
}


@end
