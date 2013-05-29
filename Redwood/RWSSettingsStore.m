//
//  RWSSettingsStore.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//

#import "RWSSettingsStore.h"
#import "RWSDebug.h"

@implementation RWSSettingsStore

+ (RWSSettingsStore *)defaultStore
{
    static RWSSettingsStore *defaultStore = nil;
    if (!defaultStore){
        defaultStore = [[super allocWithZone:nil]init];
    }
    return defaultStore;
}


//For singleton
+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultStore];
}

- (id) init
{
    self = [super init];
    if (self) {
        //try to load settings from archive
        NSString *path = [self settingsArchivePath];        
        settings = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // If the object hasn't been saved previously, create a new empty one
        if(!settings){
            settings = [[RWSSettings alloc]init];
        }         
    }
    return self;
    
}

- (RWSSettings *) settings
{
    return settings;
}


- (NSString *)settingsArchivePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"settings.archive"];
}

- (BOOL)saveChanges
{
    // returns success or failure
    NSString *path = [self settingsArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:settings
                                       toFile:path];
}



@end
