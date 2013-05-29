//
//  RWSLocationItemStore.h
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "RWSChannel.h"
@class RWSLocationItem;

@interface RWSLocationItemStore : NSObject
{
    NSMutableArray *allItems;
}

+ (RWSLocationItemStore *)defaultStore;
- (NSArray *)allItems;
- (RWSLocationItem *)createItem;
- (void) addItem: (RWSLocationItem *)p;
- (void) removeItem:(RWSLocationItem *)p;
- (void) removeAllItems;
- (void)moveItemAtIndex:(int)from
                toIndex:(int)to;
- (NSString *)itemArchivePath;
- (BOOL)saveChanges;

- (void)fetchSearchLocations:(NSString *)searchText withCompletion:(void (^)(RWSChannel *obj, NSError *err))block;

- (void)fetchLocation:(int)locationId withCompletion:(void (^)(RWSChannel *obj, NSError *err))block;

- (void)updateLocation:(int)locationId 
             sceneName:(NSString *)sceneName 
        withCompletion:(void (^)(RWSChannel *obj, NSError *err))block;

- (void)fetchAllLocationsWithCompletion:(void (^)(RWSChannel *obj, NSError *err))block;



@end
