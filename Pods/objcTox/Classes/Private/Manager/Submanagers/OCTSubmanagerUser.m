//
//  OCTSubmanagerUser.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 16.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTSubmanagerUser+Private.h"
#import "OCTTox.h"

@interface OCTSubmanagerUser()

@property (weak, nonatomic) id<OCTSubmanagerDataSource> dataSource;

@end

@implementation OCTSubmanagerUser

#pragma mark -  Properties

- (NSString *)userAddress
{
    return [self.dataSource managerGetTox].userAddress;
}

- (NSString *)publicKey
{
    return [self.dataSource managerGetTox].publicKey;
}

- (OCTToxNoSpam)nospam
{
    return [self.dataSource managerGetTox].nospam;
}

- (void)setNospam:(OCTToxNoSpam)nospam
{
    [self.dataSource managerGetTox].nospam = nospam;
}

- (OCTToxUserStatus)userStatus
{
    return [self.dataSource managerGetTox].userStatus;
}

- (void)setUserStatus:(OCTToxUserStatus)userStatus
{
    [self.dataSource managerGetTox].userStatus = userStatus;
}

#pragma mark -  Public

- (BOOL)setUserName:(NSString *)name error:(NSError **)error
{
    return [[self.dataSource managerGetTox] setNickname:name error:error];
}

- (NSString *)userName
{
    return [[self.dataSource managerGetTox] userName];
}

- (BOOL)setUserStatusMessage:(NSString *)statusMessage error:(NSError **)error
{
    return [[self.dataSource managerGetTox] setUserStatusMessage:statusMessage error:error];
}

- (NSString *)userStatusMessage
{
    return [[self.dataSource managerGetTox] userStatusMessage];
}

@end
