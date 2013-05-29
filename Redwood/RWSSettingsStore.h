//
//  RWSSettingsStore.h
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWSSettings.h"
@class RWSSettings;

@interface RWSSettingsStore : NSObject
{
    RWSSettings *settings;
}

+ (RWSSettingsStore *)defaultStore;
- (RWSSettings *)settings;
- (NSString *)settingsArchivePath;
- (BOOL)saveChanges;


@end
