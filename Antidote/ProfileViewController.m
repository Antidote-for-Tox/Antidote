//
//  ProfileViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 08.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>

#import "ProfileViewController.h"
#import "UITableViewCell+Utilities.h"
#import "CellWithNameStatusAvatar.h"
#import "CellWithToxId.h"
#import "AppContext.h"
#import "ProfileManager.h"
#import "OCTManager.h"
#import "QRViewerController.h"
#import "AvatarsManager.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeNameStatusAvatar,
    CellTypeToxId,
};

@interface ProfileViewController () <SettingsNameStatusAvatarCellDelegate, CellWithToxIdDelegate,
                                     UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ProfileViewController

#pragma mark -  Lifecycle

- (id)init
{
    return [super initWithTitle:NSLocalizedString(@"Profile", @"Profile") tableStructure:@[
                @[
                    @(CellTypeNameStatusAvatar),
                ],
                @[
                    @(CellTypeToxId),
                ]
            ]];
}

#pragma mark -  Override

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[CellWithNameStatusAvatar class]
           forCellReuseIdentifier:[CellWithNameStatusAvatar reuseIdentifier]];

    [self.tableView registerClass:[CellWithToxId class] forCellReuseIdentifier:[CellWithToxId reuseIdentifier]];
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

    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeNameStatusAvatar) {
        return [CellWithNameStatusAvatar height];
    }
    else if (type == CellTypeToxId) {
        return [CellWithToxId height];
    }

    return 0.0;
}

#pragma mark -  SettingsNameStatusAvatarCellDelegate

- (void)cellWithNameStatusAvatarAvatarButtonPressed:(CellWithNameStatusAvatar *)cell
{
    __weak ProfileViewController *weakSelf = self;

    void (^photoHandler)(UIImagePickerControllerSourceType) = ^(UIImagePickerControllerSourceType sourceType) {
        UIImagePickerController *ipc = [UIImagePickerController new];
        ipc.allowsEditing = NO;
        ipc.sourceType = sourceType;
        ipc.delegate = weakSelf;

        [weakSelf presentViewController:ipc animated:YES completion:nil];
    };

    UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:nil];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [sheet bk_addButtonWithTitle:NSLocalizedString(@"Camera", @"Profile") handler:^{
            photoHandler(UIImagePickerControllerSourceTypeCamera);
        }];
    }

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [sheet bk_addButtonWithTitle:NSLocalizedString(@"Photo Library", @"Profile") handler:^{
            photoHandler(UIImagePickerControllerSourceTypePhotoLibrary);
        }];
    }

    // FIXME avatar
    // if ([[ToxManager sharedInstance] userHasAvatar]) {
    //     [sheet bk_setDestructiveButtonWithTitle:NSLocalizedString(@"Delete", @"Profile") handler:^{
    //         [[ToxManager sharedInstance] updateAvatar:nil];

    //         NSIndexPath *path = [weakSelf indexPathForCellType:CellTypeNameStatusAvatar];
    //         [weakSelf.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    //     }];
    // }

    [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profile") handler:nil];

    [sheet showInView:self.view];
}

- (void)cellWithNameStatusAvatar:(CellWithNameStatusAvatar *)cell nameChangedTo:(NSString *)newName
{
    [[AppContext sharedContext].profileManager.toxManager.user setUserName:newName error:nil];

    // FIXME avatar
    // if (! [[ToxManager sharedInstance] userHasAvatar]) {
    NSIndexPath *path = [self indexPathForCellType:CellTypeNameStatusAvatar];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
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

- (CellWithNameStatusAvatar *)cellWithNameStatusAvatarAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [CellWithNameStatusAvatar reuseIdentifier];

    CellWithNameStatusAvatar *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier
                                                                          forIndexPath:indexPath];

    NSString *userName = [AppContext sharedContext].profileManager.toxManager.user.userName;

    cell.delegate = self;
    cell.avatarImage = [[AppContext sharedContext].avatars avatarFromString:userName
                                                                   diameter:[CellWithNameStatusAvatar avatarHeight]];
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
    cell.title = NSLocalizedString(@"My Tox ID", @"Profile");
    cell.toxId = [AppContext sharedContext].profileManager.toxManager.user.userAddress;

    [cell redraw];

    return cell;
}

@end
