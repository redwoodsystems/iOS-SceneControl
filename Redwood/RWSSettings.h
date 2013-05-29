//
//  RWSSettings.h
//  Table4
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface RWSSettings : NSObject <NSCoding>
{    

}

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *clusterName;
@property (nonatomic) int lastPickedLocationId;
@property (nonatomic) BOOL shouldRefreshLocations;


@end
