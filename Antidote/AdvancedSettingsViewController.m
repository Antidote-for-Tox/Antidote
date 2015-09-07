//
//  AdvancedSettingsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 31.01.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/UIActionSheet+BlocksKit.h>

#import "AdvancedSettingsViewController.h"
#import "UITableViewCell+Utilities.h"
#import "CellWithSwitch.h"
#import "UserDefaultsManager.h"
#import "AppearanceManager.h"
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
    return [super initWithTitle:NSLocalizedString(@"Advanced Settings", @"Settings") tableStyle:UITableViewStyleGrouped tableStructure:@[
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

    if ((type == CellTypeIpv6Enabled) || (type == CellTypeUdpEnabled)) {
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
        UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:NSLocalizedString(@"This will reset all settings. Are you sure?", @"Settings")];
        [sheet bk_setDestructiveButtonWithTitle:NSLocalizedString(@"Restore", @"Settings") handler:^{
            [[AppContext sharedContext] restoreDefaultSettings];
        }];
        [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Settings") handler:nil];
        [sheet showInView:self.view];
    }
}

#pragma mark -  CellWithSwitchDelegate

- (void)cellWithSwitchStateChanged:(CellWithSwitch *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    CellType type = [self cellTypeForIndexPath:path];

    if (type == CellTypeIpv6Enabled) {
        [AppContext sharedContext].userDefaults.uIpv6Enabled = cell.on ? @(1) : @(0);
    }
    else if (type == CellTypeUdpEnabled) {
        [AppContext sharedContext].userDefaults.uUDPEnabled = cell.on ? @(1) : @(0);
    }

    [self reloadToxManager];
}

#pragma mark -  Private

- (void)reloadToxManager
{
    // FIXME
    // ProfileManager *profileManager = [AppContext sharedContext].profileManager;
    // [profileManager switchToProfileWithName:profileManager.currentProfileName];
    // [profileManager updateInterface];
}

- (CellWithSwitch *)cellWithSwitchAtIndexPath:(NSIndexPath *)indexPath type:(CellType)type
{
    CellWithSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:[CellWithSwitch reuseIdentifier]
                                                                forIndexPath:indexPath];
    cell.delegate = self;

    if (type == CellTypeIpv6Enabled) {
        cell.title = NSLocalizedString(@"IPv6 enabled", @"Settings");
        cell.on = [AppContext sharedContext].userDefaults.uIpv6Enabled.unsignedIntegerValue > 0;
    }
    else if (type == CellTypeUdpEnabled) {
        cell.title = NSLocalizedString(@"UDP enabled", @"Settings");
        cell.on = [AppContext sharedContext].userDefaults.uUDPEnabled.unsignedIntegerValue > 0;
    }

    return cell;
}

- (UITableViewCell *)restoreDefaultCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kRestoreDefaultReuseIdentifier
                                                                 forIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(@"Restore default settings", @"Settings");

    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [[AppContext sharedContext].appearance textMainColor];

    return cell;
}

@end
