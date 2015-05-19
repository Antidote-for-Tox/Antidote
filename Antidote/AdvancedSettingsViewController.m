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
#import "ProfileManager.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeIpv6Enabled,
    CellTypeUdpEnabled,
    CellTypeRestoreDefault,
};

static NSString *const kRestoreDefaultReuseIdentifier = @"kRestoreDefaultReuseIdentifier";

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
        @[
            @(CellTypeRestoreDefault),
        ]
    ]];
}

#pragma mark -  Overridden methods

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[CellWithSwitch class] forCellReuseIdentifier:[CellWithSwitch reuseIdentifier]];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRestoreDefaultReuseIdentifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeIpv6Enabled ||
        type == CellTypeUdpEnabled)
    {
        return [self cellWithSwitchAtIndexPath:indexPath type:type];
    }
    else if (type == CellTypeRestoreDefault) {
        return [self restoreDefaultCellAtIndexPath:indexPath];
    }

    return [UITableViewCell new];
}

#pragma mark -  UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeRestoreDefault) {
        [UserInfoManager sharedInstance].uIpv6Enabled = nil;
        [UserInfoManager sharedInstance].uUdpDisabled = nil;

        [[UserInfoManager sharedInstance] createDefaultValuesIfNeeded];

        [self.tableView reloadData];

        [self reloadTox];
    }
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

    [self reloadTox];
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

- (UITableViewCell *)restoreDefaultCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kRestoreDefaultReuseIdentifier
                                                                 forIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(@"Restore default", @"Settings");

    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [[AppContext sharedContext].appearance textMainColor];

    return cell;
}

- (void)reloadTox
{
    DDLogInfo(@"Settings: reloading Tox");

    ProfileManager *manager = [ProfileManager sharedInstance];

    [manager switchToProfile:manager.currentProfile];
}

@end
