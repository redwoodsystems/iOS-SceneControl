//
//  RWSConnection.h
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface RWSConnection : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSURLConnection *internalConnection;
    NSMutableData *container;
    BOOL shouldAllowSelfSignedCert;
}

- (id)initWithRequest:(NSURLRequest *)req;

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) void (^completionBlock)(id obj, NSError *err);
@property (nonatomic, strong) id <JSONSerializable> jsonRootObject;
- (void)start;

@end
