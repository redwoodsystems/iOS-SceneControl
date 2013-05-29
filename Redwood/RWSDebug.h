//
//  RWSDebug.h
//
//  Created by Vivek Phalak on 7/19/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#ifdef DEBUG
#define DLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... ) 
#endif