//
//  RWSChannel.h
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

typedef enum {
    SearchLocation,
    GetLocationById,
    UpdateLocation,
    GetAllLocations
} ApiRequestType;


@interface RWSChannel : NSObject <JSONSerializable>
{
    NSMutableString *currentString;
    ApiRequestType apiRequestType;
    
}

@property (nonatomic, readonly, strong) NSMutableArray *items;
@property (nonatomic) ApiRequestType apiRequestType;
@property (nonatomic) NSDictionary *postJsonResponse;


@end
