//
//  RWSLocationItem.h
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface RWSLocationItem : NSObject <NSCoding, JSONSerializable>
{
    
}

@property (nonatomic, copy) NSString *locationName;
@property (nonatomic) int locationId;
@property (nonatomic) BOOL hasScenes;
@property (nonatomic,copy) NSString *activeSceneName;
@property (nonatomic,copy) NSMutableArray *scenes;
@property (nonatomic,copy) NSString *lastActiveSceneName;

- (void)readFromJSONDictionary:(NSDictionary *)d;
- (void)readFromJSONObject:(NSObject *)d;
- (void)readFromJSONDictionaryAllLocations:(NSDictionary *)d;


@end
