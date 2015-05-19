//
//  OCTDefaultSettingsStorage.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 07.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTDefaultSettingsStorage.h"

@interface OCTDefaultSettingsStorage()

@property (strong, nonatomic, readwrite) NSString *userDefaultsKey;

@end

@implementation OCTDefaultSettingsStorage

#pragma mark -  Lifecycle

- (instancetype)initWithUserDefaultsKey:(NSString *)userDefaultsKey
{
    self = [super init];

    if (! self) {
        return nil;
    }

    _userDefaultsKey = userDefaultsKey;

    return self;
}

#pragma mark -  OCTSettingsStorageProtocol

- (void)setObject:(id)object forKey:(NSString *)key
{
    NSParameterAssert(object);
    NSParameterAssert(key);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSDictionary *dict = [defaults objectForKey:self.userDefaultsKey];
    NSMutableDictionary *mutableDict;

    if (dict) {
        mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    else {
        mutableDict = [NSMutableDictionary new];
    }

    mutableDict[key] = object;

    [defaults setObject:[mutableDict copy] forKey:self.userDefaultsKey];
    [defaults synchronize];
}

- (id)objectForKey:(NSString *)key
{
    NSParameterAssert(key);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults objectForKey:self.userDefaultsKey];

    return dict[key];
}

@end
