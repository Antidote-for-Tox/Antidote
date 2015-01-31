//
//  AdvancedSettingsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 31.01.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "AdvancedSettingsViewController.h"
#import "UITableViewCell+Utilities.h"
#import "CellWithSwitch.h"
#import "UserInfoManager.h"

typedef NS_ENUM(NSUInteger, CellType) {
    CellTypeIpv6Enabled,
    CellTypeUdpEnabled,
};

@interface AdvancedSettingsViewController () <CellWithSwitchDelegate>

@end

@implementation AdvancedSettingsViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    return [super initWithTitle:NSLocalizedString(@"Advanced Settings", @"Settings") tableStructure:@[
        @[
            @(CellTypeIpv6Enabled),
            @(CellTypeUdpEnabled),
        ],
    ]];
}

#pragma mark -  Overridden methods

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[CellWithSwitch class] forCellReuseIdentifier:[CellWithSwitch reuseIdentifier]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeIpv6Enabled ||
             type == CellTypeUdpEnabled)
    {
        return [self cellWithSwitchAtIndexPath:indexPath type:type];
    }

    return [UITableViewCell new];
}

#pragma mark -  CellWithSwitchDelegate

- (void)cellWithSwitchStateChanged:(CellWithSwitch *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    CellType type = [self cellTypeForIndexPath:path];

    if (type == CellTypeIpv6Enabled) {
        [UserInfoManager sharedInstance].uIpv6Enabled = cell.on ? @(1) : @(0);
    }
    else if (type == CellTypeUdpEnabled) {
        [UserInfoManager sharedInstance].uUdpDisabled = cell.on ? @(0) : @(1);
    }
}

#pragma mark -  Private

- (CellWithSwitch *)cellWithSwitchAtIndexPath:(NSIndexPath *)indexPath type:(CellType)type
{
    CellWithSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:[CellWithSwitch reuseIdentifier]
                                                                forIndexPath:indexPath];
    cell.delegate = self;

    if (type == CellTypeIpv6Enabled) {
        cell.title = NSLocalizedString(@"IPv6 enabled", @"Settings");
        cell.on = [UserInfoManager sharedInstance].uIpv6Enabled.unsignedIntegerValue > 0;
    }
    else if (type == CellTypeUdpEnabled) {
        cell.title = NSLocalizedString(@"UDP enabled", @"Settings");
        cell.on = [UserInfoManager sharedInstance].uUdpDisabled.unsignedIntegerValue == 0;
    }

    return cell;
}

@end
