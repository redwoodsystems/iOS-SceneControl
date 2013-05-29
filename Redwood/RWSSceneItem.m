//
//  RWSSceneItem.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import "RWSSceneItem.h"
#import "RWSDebug.h"

@implementation RWSSceneItem
@synthesize sceneName,locationId,isActive,order;
@synthesize location;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:sceneName forKey:@"sceneName"];
    [aCoder encodeInt:locationId forKey:@"locationId"];
    [aCoder encodeBool:isActive forKey:@"isActive"];
    [aCoder encodeInt:order forKey:@"order"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setLocationId:[aDecoder decodeIntForKey:@"locationId"]];
        [self setSceneName:[aDecoder decodeObjectForKey:@"sceneName"]];
        [self setIsActive:[aDecoder decodeBoolForKey:@"isActive"]];
        [self setOrder:[aDecoder decodeIntForKey:@"order"]];
        [self setLocation:nil];
    }
    return self;
}

- (id) initWithSceneName: (NSString *)scName
              locationId: (int) locId
                location: (RWSLocationItem *)locItem
                isActive: (BOOL) isAct
                order: (int) ord
{
    self = [super init];
    if (self) {
        [self setSceneName:scName];
        [self setLocationId:locId];
        [self setIsActive:isAct];
        [self setLocation:locItem];
        [self setOrder:ord];
    }
    return self;
}

- (id) init
{
    return ([self initWithSceneName:@"No Scene" locationId:0 location:nil isActive:NO order:0]);
}

@end
