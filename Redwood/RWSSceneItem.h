//
//  RWSSceneItem.h
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
@class RWSLocationItem;

@interface RWSSceneItem : NSObject<NSCoding>
{
    
}

@property (nonatomic, copy) NSString *sceneName;
@property (nonatomic) int locationId;
@property (nonatomic) BOOL isActive;
@property (nonatomic) int order;
@property (nonatomic, weak) RWSLocationItem *location;  //parent location

- (id) initWithSceneName: (NSString *)scName
              locationId: (int) locId
                location: (RWSLocationItem *)locItem
                isActive: (BOOL) isAct
                   order: (int) ord;
- (id) init;

@end
