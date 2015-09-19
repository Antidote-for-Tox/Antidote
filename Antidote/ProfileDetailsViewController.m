//
//  ProfileDetailsViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 19/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <objcTox/OCTManager.h>
#import <objcTox/OCTManagerConfiguration.h>

#import "ProfileDetailsViewController.h"
#import "ContentSeparatorCell.h"
#import "ContentCellSimple.h"
#import "UITableViewCell+Utilities.h"
#import "UserDefaultsManager.h"
#import "RunningContext.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeSeparatorTransparent,
    CellTypeSeparatorGray,
    CellTypeProfileName,
    CellTypePassword,
    CellTypeNospam,
    CellTypeExportProfile,
    CellTypeDeleteProfile,
};

@interface ProfileDetailsViewController ()

@end

@implementation ProfileDetailsViewController

#pragma mark -  Lifecycle

- (id)init
{
    return [super initWithTitle:NSLocalizedString(@"Profile", @"Profile") tableStyle:UITableViewStylePlain tableStructure:@[
                @[
                    @(CellTypeSeparatorTransparent),
                    @(CellTypeProfileName),
                    @(CellTypePassword),
                    @(CellTypeNospam),
                ],
                @[
                    @(CellTypeSeparatorGray),
                    @(CellTypeExportProfile),
                    @(CellTypeDeleteProfile),
                ],
            ]];
}

#pragma mark -  Override

- (void)configureTableView
{
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[ContentSeparatorCell class] forCellReuseIdentifier:[ContentSeparatorCell reuseIdentifier]];
    [self.tableView registerClass:[ContentCellSimple class] forCellReuseIdentifier:[ContentCellSimple reuseIdentifier]];
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    switch (type) {
        case CellTypeSeparatorTransparent:
            return [self separatorCellAtIndexPath:indexPath isGray:NO];
        case CellTypeSeparatorGray:
            return [self separatorCellAtIndexPath:indexPath isGray:YES];
        case CellTypeProfileName:
            return [self profileNameCellAtIndexPath:indexPath];
        case CellTypePassword:
            return [self passwordCellAtIndexPath:indexPath];
        case CellTypeNospam:
            return [self nospamCellAtIndexPath:indexPath];
        case CellTypeExportProfile:
            return [self exportProfileCellAtIndexPath:indexPath];
        case CellTypeDeleteProfile:
            return [self deleteProfileCellAtIndexPath:indexPath];
    }
}

#pragma mark -  Private

- (ContentSeparatorCell *)separatorCellAtIndexPath:(NSIndexPath *)indexPath isGray:(BOOL)isGray
{
    ContentSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[ContentSeparatorCell reuseIdentifier]
                                                                      forIndexPath:indexPath];
    cell.showGraySeparator = isGray;

    return cell;
}

- (ContentCellSimple *)profileNameCellAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCellSimple *cell = [self simpleCellAtIndexPath:indexPath];

    cell.title = NSLocalizedString(@"Profile Name", @"ProfileDetailsViewController");
    cell.detailTitle = [AppContext sharedContext].userDefaults.uLastActiveProfile;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (ContentCellSimple *)passwordCellAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCellSimple *cell = [self simpleCellAtIndexPath:indexPath];

    cell.title = NSLocalizedString(@"Password", @"ProfileDetailsViewController");
    cell.detailTitle = [RunningContext context].toxManager.configuration.passphrase ?
                       NSLocalizedString(@"Yes", @"ProfileDetailsViewController") :
                       NSLocalizedString(@"No", @"ProfileDetailsViewController");
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (ContentCellSimple *)nospamCellAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCellSimple *cell = [self simpleCellAtIndexPath:indexPath];

    cell.title = NSLocalizedString(@"Nospam", @"ProfileDetailsViewController");
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (ContentCellSimple *)exportProfileCellAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCellSimple *cell = [self simpleCellAtIndexPath:indexPath];

    cell.title = NSLocalizedString(@"Export Profile", @"ProfileDetailsViewController");
    cell.boldTitle = YES;

    return cell;
}

- (ContentCellSimple *)deleteProfileCellAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCellSimple *cell = [self simpleCellAtIndexPath:indexPath];

    cell.title = NSLocalizedString(@"Delete Profile", @"ProfileDetailsViewController");
    cell.boldTitle = YES;
    cell.titleColor = [UIColor redColor];

    return cell;
}

- (ContentCellSimple *)simpleCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ContentCellSimple reuseIdentifier];
    ContentCellSimple *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell resetCell];

    return cell;
}

@end
