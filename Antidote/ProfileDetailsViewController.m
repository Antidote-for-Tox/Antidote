//
//  ProfileDetailsViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 19/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <objcTox/OCTManager.h>
#import <objcTox/OCTManagerConfiguration.h>

#import "ProfileDetailsViewController.h"
#import "ContentSeparatorCell.h"
#import "ContentCellSimple.h"
#import "UITableViewCell+Utilities.h"
#import "UserDefaultsManager.h"
#import "RunningContext.h"
#import "ErrorHandler.h"
#import "LifecycleManager.h"
#import "LifecyclePhaseRunning.h"
#import "ProfileManager.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeSeparatorTransparent,
    CellTypeSeparatorGray,
    CellTypeProfileName,
    CellTypePassword,
    CellTypeNospam,
    CellTypeExportProfile,
    CellTypeDeleteProfile,
};

@interface ProfileDetailsViewController () <UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation ProfileDetailsViewController

#pragma mark -  Lifecycle

- (id)init
{
    return [super initWithTitle:NSLocalizedString(@"Profile Details", @"ProfileDetailsViewController") tableStyle:UITableViewStylePlain tableStructure:@[
                @[]
                // @(CellTypeSeparatorTransparent),
                // @(CellTypeProfileName),
                // @(CellTypePassword),
                // @(CellTypeNospam),
                ,
                @[
                    // @(CellTypeSeparatorGray),
                    @(CellTypeSeparatorTransparent),
                    @(CellTypeExportProfile),
                    @(CellTypeSeparatorGray),
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeExportProfile) {
        [self exportProfile];
    }
    else if (type == CellTypeDeleteProfile) {
        [self deleteProfile];
    }
}

#pragma mark -  UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
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

    return cell;
}

- (ContentCellSimple *)deleteProfileCellAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCellSimple *cell = [self simpleCellAtIndexPath:indexPath];

    cell.title = NSLocalizedString(@"Delete Profile", @"ProfileDetailsViewController");

    return cell;
}

- (ContentCellSimple *)simpleCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ContentCellSimple reuseIdentifier];
    ContentCellSimple *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell resetCell];

    return cell;
}

- (void)exportProfile
{
    NSError *error;

    NSString *path = [[RunningContext context].toxManager exportToxSaveFile:&error];

    if (! path) {
        [[AppContext sharedContext].errorHandler handleError:error type:ErrorHandlerTypeExportProfile];
        return;
    }

    NSURL *url = [NSURL fileURLWithPath:path];

    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    self.documentInteractionController.delegate = self;
    self.documentInteractionController.name = [NSString stringWithFormat:@"%@.tox",
                                               [AppContext sharedContext].userDefaults.uLastActiveProfile];

    [self.documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
}

- (void)deleteProfile
{
    NSString *firstTitle = NSLocalizedString(@"Are you sure you want to delete profile?\nThis operation cannot be undone!", @"ProfileDetailsViewController");
    NSString *secondTitle = NSLocalizedString(@"Delete profile?", @"ProfileDetailsViewController");
    NSString *delete = NSLocalizedString(@"Delete", @"ProfileDetailsViewController");
    NSString *cancel = NSLocalizedString(@"Cancel", @"ProfileDetailsViewController");

    UIActionSheet *firstSheet = [UIActionSheet bk_actionSheetWithTitle:firstTitle];

    weakself;
    [firstSheet bk_setDestructiveButtonWithTitle:delete handler:^{
        UIActionSheet *secondSheet = [UIActionSheet bk_actionSheetWithTitle:secondTitle];

        [secondSheet bk_setDestructiveButtonWithTitle:delete handler:^{
            strongself;

            [self reallyDeleteProfile];
        }];
        [secondSheet bk_setCancelButtonWithTitle:cancel handler:nil];

        [secondSheet showInView:self.view];
    }];
    [firstSheet bk_setCancelButtonWithTitle:cancel handler:nil];

    [firstSheet showInView:self.view];
}

- (void)reallyDeleteProfile
{
    LifecyclePhaseRunning *running = (LifecyclePhaseRunning *) [[AppContext sharedContext].lifecycleManager currentPhase];

    NSAssert([running isKindOfClass:[LifecyclePhaseRunning class]],
             @"Something went terrible wrong, should be in running phase");

    NSString *profileName = [AppContext sharedContext].userDefaults.uLastActiveProfile;

    [running logoutWithCompletionBlock:^{
        ProfileManager *profileManager = [ProfileManager new];

        NSError *error;
        if ([profileManager deleteProfileWithName:profileName error:&error]) {
            [AppContext sharedContext].userDefaults.uLastActiveProfile = nil;
        }
        else {
            [[AppContext sharedContext].errorHandler handleError:error type:ErrorHandlerTypeDeleteProfile];
        }
    }];
}

@end
