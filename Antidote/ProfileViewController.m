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
#import "AppContext.h"
#import "ProfileManager.h"
#import "OCTManager.h"
#import "QRViewerController.h"
#import "AvatarsManager.h"
#import "ContentCellWithTitle.h"
#import "ContentCellWithAvatar.h"
#import "ContentSeparatorCell.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeSeparatorTransparent,
    CellTypeSeparatorGray,
    CellTypeAvatar,
    CellTypeName,
    CellTypeStatusMessage,
    CellTypeToxId,
};

@interface ProfileViewController () <ContentCellWithTitleDelegate, ContentCellWithAvatarDelegate,
                                     UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ProfileViewController

#pragma mark -  Lifecycle

- (id)init
{
    return [super initWithTitle:NSLocalizedString(@"Profile", @"Profile") tableStyle:UITableViewStylePlain tableStructure:@[
                @[
                    @(CellTypeSeparatorTransparent),
                    @(CellTypeAvatar),
                    @(CellTypeSeparatorGray),
                    @(CellTypeName),
                    @(CellTypeStatusMessage),
                    @(CellTypeSeparatorGray),
                    @(CellTypeToxId),
                ]
            ]];
}

#pragma mark -  Override

- (void)configureTableView
{
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[ContentSeparatorCell class] forCellReuseIdentifier:[ContentSeparatorCell reuseIdentifier]];
    [self.tableView registerClass:[ContentCellWithAvatar class] forCellReuseIdentifier:[ContentCellWithAvatar reuseIdentifier]];
    [self.tableView registerClass:[ContentCellWithTitle class] forCellReuseIdentifier:[ContentCellWithTitle reuseIdentifier]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    switch (type) {
        case CellTypeSeparatorTransparent:
            return [self separatorCellAtIndexPath:indexPath isGray:NO];
        case CellTypeSeparatorGray:
            return [self separatorCellAtIndexPath:indexPath isGray:YES];
        case CellTypeAvatar:
            return [self cellWithAvatarAtIndexPath:indexPath];
        case CellTypeName:
            return [self cellWithNameAtIndexPath:indexPath];
        case CellTypeStatusMessage:
            return [self cellWithStatusMessageAtIndexPath:indexPath];
        case CellTypeToxId:
            return [self cellWithToxIdAtIndexPath:indexPath];
    }
}

#pragma mark -  ContentCellWithAvatarDelegate

- (void)contentCellWithAvatarImagePressed:(ContentCellWithAvatar *)cell
{
    weakself;

    void (^photoHandler)(UIImagePickerControllerSourceType) = ^(UIImagePickerControllerSourceType sourceType) {
        strongself;

        UIImagePickerController *ipc = [UIImagePickerController new];
        ipc.allowsEditing = NO;
        ipc.sourceType = sourceType;
        ipc.delegate = self;

        [self presentViewController:ipc animated:YES completion:nil];
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

    //         NSIndexPath *path = [weakSelf indexPathForCellType:CellTypeAvatar];
    //         [weakSelf.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    //     }];
    // }

    [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profile") handler:nil];

    [sheet showInView:self.view];
}

#pragma mark -  ContentCellWithTitleDelegate

- (void)contentCellWithTitleDidPressButton:(ContentCellWithTitle *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    CellType type = indexPath.row;

    switch (type) {
        case CellTypeToxId:
            [self presentViewController:[[QRViewerController alloc] initWithToxId:cell.mainText] animated:YES completion:nil];
            break;
        case CellTypeSeparatorTransparent:
        case CellTypeSeparatorGray:
        case CellTypeAvatar:
        case CellTypeName:
        case CellTypeStatusMessage:
            // nop
            break;
    }
}

- (void)contentCellWithTitleDidBeginEditing:(ContentCellWithTitle *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)contentCellWithTitleWantsToResize:(ContentCellWithTitle *)cell
{
    // This forces tableView to nicely animate change of cell's frame without reloading it.
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)contentCellWithTitle:(ContentCellWithTitle *)cell didChangeMainText:(NSString *)mainText
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    CellType type = indexPath.row;

    switch (type) {
        case CellTypeName: {
            [[AppContext sharedContext].profileManager.toxManager.user setUserName:mainText error:nil];

            // FIXME avatar
            // if (! [[ToxManager sharedInstance] userHasAvatar]) {
            NSIndexPath *path = [self indexPathForCellType:CellTypeAvatar];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
            // }
            break;
        }
        case CellTypeStatusMessage:
            [[AppContext sharedContext].profileManager.toxManager.user setUserStatusMessage:mainText error:nil];
            break;
        case CellTypeSeparatorTransparent:
        case CellTypeSeparatorGray:
        case CellTypeAvatar:
        case CellTypeToxId:
            // nop
            break;
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

    NSIndexPath *path = [self indexPathForCellType:CellTypeAvatar];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -  Private

- (ContentSeparatorCell *)separatorCellAtIndexPath:(NSIndexPath *)indexPath isGray:(BOOL)isGray
{
    ContentSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[ContentSeparatorCell reuseIdentifier]
                                                                      forIndexPath:indexPath];
    cell.showGraySeparator = isGray;

    return cell;
}

- (ContentCellWithAvatar *)cellWithAvatarAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCellWithAvatar *cell = [self.tableView dequeueReusableCellWithIdentifier:[ContentCellWithAvatar reuseIdentifier]
                                                                       forIndexPath:indexPath];
    cell.delegate = self;

    NSString *userName = [AppContext sharedContext].profileManager.toxManager.user.userName;
    cell.avatar = [[AppContext sharedContext].avatars avatarFromString:userName diameter:kContentCellWithAvatarImageSize];

    return cell;
}

- (ContentCellWithTitle *)cellWithNameAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCellWithTitle *cell = [self.tableView dequeueReusableCellWithIdentifier:[ContentCellWithTitle reuseIdentifier]
                                                                      forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"Name", @"Profile");
    cell.buttonTitle = nil;
    cell.mainText = [AppContext sharedContext].profileManager.toxManager.user.userName;
    cell.maxMainTextLength = kOCTToxMaxNameLength;
    cell.editable = YES;

    return cell;
}

- (ContentCellWithTitle *)cellWithStatusMessageAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCellWithTitle *cell = [self.tableView dequeueReusableCellWithIdentifier:[ContentCellWithTitle reuseIdentifier]
                                                                      forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"Status Message", @"Profile");
    cell.buttonTitle = nil;
    cell.mainText = [AppContext sharedContext].profileManager.toxManager.user.userStatusMessage;
    cell.maxMainTextLength = kOCTToxMaxStatusMessageLength;
    cell.editable = YES;

    return cell;
}

- (ContentCellWithTitle *)cellWithToxIdAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCellWithTitle *cell = [self.tableView dequeueReusableCellWithIdentifier:[ContentCellWithTitle reuseIdentifier]
                                                                      forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"My Tox ID", @"Profile");
    cell.buttonTitle = NSLocalizedString(@"Show QR", @"Profile");
    cell.mainText = [AppContext sharedContext].profileManager.toxManager.user.userAddress;
    cell.editable = NO;

    return cell;
}

@end
