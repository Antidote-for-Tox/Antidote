//
//  SettingsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "SettingsViewController.h"
#import "QRViewerController.h"
#import "UIView+Utilities.h"
#import "AppDelegate.h"
#import "MFMailComposeViewController+BlocksKit.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "DDFileLogger.h"
#import "UITableViewCell+Utilities.h"
#import "CellWithNameStatusAvatar.h"
#import "CellWithToxId.h"
#import "CellWithColorscheme.h"
#import "CellWithSwitch.h"
#import "ProfilesViewController.h"
#import "AdvancedSettingsViewController.h"
#import "ProfileManager.h"
#import "UserDefaultsManager.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeNameStatusAvatar,
    CellTypeToxId,
    CellTypeColorscheme,
    CellTypeFeedback,
    CellTypeTitleNotifications,
    CellTypeShowMessageInLocalNotification,
    CellTypeAdvancedSettings,
    CellTypeProfile,
};

static NSString *const kProfileReuseIdentifier = @"kProfileReuseIdentifier";
static NSString *const kFeedbackReuseIdentifier = @"kFeedbackReuseIdentifier";

@interface SettingsViewController () <SettingsNameStatusAvatarCellDelegate, CellWithToxIdDelegate,
    CellWithColorschemeDelegate, CellWithSwitchDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate>

@end

@implementation SettingsViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    return [super initWithTitle:NSLocalizedString(@"Settings", @"Settings") tableStructure:@[
        @[
            @(CellTypeNameStatusAvatar),
        ],
        @[
            @(CellTypeToxId),
            @(CellTypeColorscheme),
        ],
        @[
            @(CellTypeProfile),
        ],
        @[
            @(CellTypeTitleNotifications),
            @(CellTypeShowMessageInLocalNotification),
        ],
        @[
            @(CellTypeAdvancedSettings),
        ],
        @[
            @(CellTypeFeedback),
        ],
    ]];
}

#pragma mark -  Overridden methods

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[CellWithNameStatusAvatar class]
           forCellReuseIdentifier:[CellWithNameStatusAvatar reuseIdentifier]];

    [self.tableView registerClass:[CellWithToxId class] forCellReuseIdentifier:[CellWithToxId reuseIdentifier]];

    [self.tableView registerClass:[CellWithColorscheme class]
           forCellReuseIdentifier:[CellWithColorscheme reuseIdentifier]];

    [self.tableView registerClass:[CellWithSwitch class] forCellReuseIdentifier:[CellWithSwitch reuseIdentifier]];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kProfileReuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFeedbackReuseIdentifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeNameStatusAvatar) {
        return [self cellWithNameStatusAvatarAtIndexPath:indexPath];
    }
    else if (type == CellTypeToxId) {
        return [self cellWithToxIdAtIndexPath:indexPath];
    }
    else if (type == CellTypeColorscheme) {
        return [self cellWithColorschemeIdAtIndexPath:indexPath];
    }
    else if (type == CellTypeTitleNotifications) {
        return [self cellWithTitleAtIndexPath:indexPath withType:type];
    }
    else if (type == CellTypeShowMessageInLocalNotification) {
        return [self cellWithSwitchAtIndexPath:indexPath type:type];
    }
    else if (type == CellTypeAdvancedSettings) {
        return [self cellWithArrowAtIndexPath:indexPath type:type];
    }
    else if (type == CellTypeProfile) {
        return [self profileCellAtIndexPath:indexPath];
    }
    else if (type == CellTypeFeedback) {
        return [self feedbackCellAtIndexPath:indexPath];
    }

    return [UITableViewCell new];
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeNameStatusAvatar) {
        return [CellWithNameStatusAvatar height];
    }
    else if (type == CellTypeToxId) {
        return [CellWithToxId height];
    }
    else if (type == CellTypeColorscheme) {
        return [CellWithColorscheme height];
    }
    else if (type == CellTypeTitleNotifications ||
             type == CellTypeShowMessageInLocalNotification ||
             type == CellTypeAdvancedSettings ||
             type == CellTypeProfile ||
             type == CellTypeFeedback)
    {
        return 44.0;
    }

    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeProfile) {
        [self.navigationController pushViewController:[ProfilesViewController new] animated:YES];
    }
    else if (type == CellTypeAdvancedSettings) {
        [self.navigationController pushViewController:[AdvancedSettingsViewController new] animated:YES];
    }
    else if (type == CellTypeFeedback) {
        if (! [MFMailComposeViewController canSendMail]) {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:NSLocalizedString(@"Please configure your mail settings", @"Settings")
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Settings")
                              otherButtonTitles:nil] show];

            return;
        }

        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:NSLocalizedString(@"Add log files?", @"Settings")];

        __weak SettingsViewController *weakSelf = self;

        [alertView bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Settings") handler:^{
            [weakSelf showMailControllerWithLogs:NO];
        }];

        [alertView bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Settings") handler:^{
            [weakSelf showMailControllerWithLogs:YES];
        }];

        [alertView show];
    }
}

#pragma mark -  SettingsNameStatusAvatarCellDelegate

- (void)cellWithNameStatusAvatarAvatarButtonPressed:(CellWithNameStatusAvatar *)cell
{
    __weak SettingsViewController *weakSelf = self;

    void (^photoHandler)(UIImagePickerControllerSourceType) = ^(UIImagePickerControllerSourceType sourceType) {
        UIImagePickerController *ipc = [UIImagePickerController new];
        ipc.allowsEditing = NO;
        ipc.sourceType = sourceType;
        ipc.delegate = weakSelf;

        [weakSelf presentViewController:ipc animated:YES completion:nil];
    };

    UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:nil];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [sheet bk_addButtonWithTitle:NSLocalizedString(@"Camera", @"Settings") handler:^{
            photoHandler(UIImagePickerControllerSourceTypeCamera);
        }];
    }

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [sheet bk_addButtonWithTitle:NSLocalizedString(@"Photo Library", @"Settings") handler:^{
            photoHandler(UIImagePickerControllerSourceTypePhotoLibrary);
        }];
    }

    // FIXME avatar
    // if ([[ToxManager sharedInstance] userHasAvatar]) {
    //     [sheet bk_setDestructiveButtonWithTitle:NSLocalizedString(@"Delete", @"Settings") handler:^{
    //         [[ToxManager sharedInstance] updateAvatar:nil];

    //         NSIndexPath *path = [weakSelf indexPathForCellType:CellTypeNameStatusAvatar];
    //         [weakSelf.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    //     }];
    // }

    [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Settings") handler:nil];

    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)cellWithNameStatusAvatar:(CellWithNameStatusAvatar *)cell nameChangedTo:(NSString *)newName
{
    [[AppContext sharedContext].profileManager.toxManager.user setUserName:newName error:nil];

    // FIXME avatar
    // if (! [[ToxManager sharedInstance] userHasAvatar]) {
    //     NSIndexPath *path = [self indexPathForCellType:CellTypeNameStatusAvatar];
    //     [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    // }
}

- (void)cellWithNameStatusAvatar:(CellWithNameStatusAvatar *)cell statusMessageChangedTo:(NSString *)newStatusMessage
{
    [[AppContext sharedContext].profileManager.toxManager.user setUserStatusMessage:newStatusMessage error:nil];
}

#pragma mark -  CellWithToxIdDelegate

- (void)cellWithToxIdQrButtonPressed:(CellWithToxId *)cell
{
    QRViewerController *qrVC = [[QRViewerController alloc] initWithToxId:cell.toxId];

    [self presentViewController:qrVC animated:YES completion:nil];
}

#pragma mark -  CellWithColorschemeDelegate

- (void)cellWithColorscheme:(CellWithColorscheme *)cell didSelectScheme:(AppearanceManagerColorscheme)scheme
{
    [AppContext sharedContext].userDefaults.uCurrentColorscheme = @(scheme);
    [[AppContext sharedContext] recreateAppearance];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [delegate recreateControllersAndShow:AppDelegateTabIndexSettings];
}

#pragma mark -  CellWithSwitchDelegate

- (void)cellWithSwitchStateChanged:(CellWithSwitch *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    CellType type = [self cellTypeForIndexPath:path];

    if (type == CellTypeShowMessageInLocalNotification) {
        [AppContext sharedContext].userDefaults.uShowMessageInLocalNotification = @(cell.on);
    }
}

#pragma mark -  UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *image = info[UIImagePickerControllerOriginalImage];

    if (! image) {
        return;
    }

    // FIXME avatar
    // [[ToxManager sharedInstance] updateAvatar:image];

    NSIndexPath *path = [self indexPathForCellType:CellTypeNameStatusAvatar];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -  Private

- (void)showMailControllerWithLogs:(BOOL)withLogs
{
    MFMailComposeViewController *vc = [MFMailComposeViewController new];
    vc.navigationBar.tintColor = [[AppContext sharedContext].appearance textMainColor];
    [vc setSubject:@"Feedback"];
    [vc setToRecipients:@[@"antidote@dvor.me"]];

    if (withLogs) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

        for (NSString *path in [delegate getLogFilesPaths]) {
            NSData *data = [NSData dataWithContentsOfFile:path];

            if (data) {
                [vc addAttachmentData:data mimeType:@"text/plain" fileName:[path lastPathComponent]];
            }
        }
    }

    vc.bk_completionBlock = ^(MFMailComposeViewController *vc, MFMailComposeResult result, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:nil];
    };

    [self presentViewController:vc animated:YES completion:nil];
}

- (CellWithNameStatusAvatar *)cellWithNameStatusAvatarAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [CellWithNameStatusAvatar reuseIdentifier];

    CellWithNameStatusAvatar *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier
                                                                          forIndexPath:indexPath];

    NSString *userName = [AppContext sharedContext].profileManager.toxManager.user.userName;

    // FIXME avatar
    // UIImage *avatar = [[ToxManager sharedInstance] userAvatar] ?:
    //     [AvatarManager avatarFromString:userName side:[CellWithNameStatusAvatar avatarHeight]];
    UIImage *avatar = nil;

    cell.delegate = self;
    cell.avatarImage = avatar;
    cell.name = userName;
    cell.statusMessage = [AppContext sharedContext].profileManager.toxManager.user.userStatusMessage;
    cell.maxNameLength = kOCTToxMaxNameLength;
    cell.maxStatusMessageLength = kOCTToxMaxStatusMessageLength;

    [cell redraw];

    return cell;
}

- (CellWithToxId *)cellWithToxIdAtIndexPath:(NSIndexPath *)indexPath
{
    CellWithToxId *cell = [self.tableView dequeueReusableCellWithIdentifier:[CellWithToxId reuseIdentifier]
                                                               forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"My Tox ID", @"Settings");
    cell.toxId = [AppContext sharedContext].profileManager.toxManager.user.userAddress;

    [cell redraw];

    return cell;
}

- (CellWithColorscheme *)cellWithColorschemeIdAtIndexPath:(NSIndexPath *)indexPath
{
    CellWithColorscheme *cell = [self.tableView dequeueReusableCellWithIdentifier:[CellWithColorscheme reuseIdentifier]
                                                                     forIndexPath:indexPath];
    cell.delegate = self;

    [cell redraw];

    return cell;
}

- (UITableViewCell *)cellWithTitleAtIndexPath:(NSIndexPath *)indexPath withType:(CellType)type
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kProfileReuseIdentifier
                                                                 forIndexPath:indexPath];

    if (type == CellTypeTitleNotifications) {
        cell.textLabel.text = NSLocalizedString(@"Notifications", @"Settings");
    }

    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.textColor = [UIColor blackColor];

    return cell;
}

- (CellWithSwitch *)cellWithSwitchAtIndexPath:(NSIndexPath *)indexPath type:(CellType)type
{
    CellWithSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:[CellWithSwitch reuseIdentifier]
                                                                forIndexPath:indexPath];
    cell.delegate = self;

    if (type == CellTypeShowMessageInLocalNotification) {
        cell.title = NSLocalizedString(@"Message preview", @"Settings");
        cell.on = [AppContext sharedContext].userDefaults.uShowMessageInLocalNotification.boolValue;
    }

    return cell;
}

- (UITableViewCell *)cellWithArrowAtIndexPath:(NSIndexPath *)indexPath type:(CellType)type
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kProfileReuseIdentifier
                                                                 forIndexPath:indexPath];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (type == CellTypeAdvancedSettings) {
        cell.textLabel.text = NSLocalizedString(@"Advanced Settings", @"Settings");
    }

    return cell;
}

- (UITableViewCell *)profileCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kProfileReuseIdentifier
                                                                 forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",
        NSLocalizedString(@"Profile", @"Settings"),
        [AppContext sharedContext].profileManager.currentProfileName];

    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [[AppContext sharedContext].appearance textMainColor];

    return cell;
}

- (UITableViewCell *)feedbackCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kFeedbackReuseIdentifier
                                                                 forIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(@"Feedback", @"Settings");
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [[AppContext sharedContext].appearance textMainColor];

    return cell;
}

@end
