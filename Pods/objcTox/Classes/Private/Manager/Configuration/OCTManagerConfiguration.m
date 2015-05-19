//
//  OCTManagerConfiguration.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 08.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTManagerConfiguration.h"
#import "OCTDefaultSettingsStorage.h"
#import "OCTDefaultFileStorage.h"

static NSString *const kDefaultSettingsStorageUserDefaultsKey = @"me.dvor.objcTox.settings";
static NSString *const kDefaultBaseDirectory = @"me.dvor.objcTox";

@implementation OCTManagerConfiguration

#pragma mark -  Class methods

+ (instancetype)defaultConfiguration
{
    OCTManagerConfiguration *configuration = [OCTManagerConfiguration new];

    configuration.settingsStorage = [[OCTDefaultSettingsStorage alloc]
        initWithUserDefaultsKey:kDefaultSettingsStorageUserDefaultsKey];

    NSString *baseDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    baseDirectory = [baseDirectory stringByAppendingPathComponent:kDefaultBaseDirectory];

    [[NSFileManager defaultManager] createDirectoryAtPath:baseDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];

    configuration.fileStorage = [[OCTDefaultFileStorage alloc] initWithBaseDirectory:baseDirectory
                                                                  temporaryDirectory:NSTemporaryDirectory()];

    configuration.options = [OCTToxOptions new];
    configuration.options.IPv6Enabled = YES;
    configuration.options.UDPEnabled = YES;
    configuration.options.startPort = 0;
    configuration.options.endPort = 0;
    configuration.options.proxyType = OCTToxProxyTypeNone;
    configuration.options.proxyHost = nil;
    configuration.options.proxyPort = 0;

    return configuration;
}

#pragma mark -  NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    OCTManagerConfiguration *configuration = [[[self class] allocWithZone:zone] init];

    configuration.settingsStorage = self.settingsStorage;
    configuration.fileStorage = self.fileStorage;
    configuration.options = [self.options copy];

    return configuration;
}

@end
