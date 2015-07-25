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
#import "ContentCellWithTitleImmutable.h"
#import "ContentCellWithTitleEditable.h"
#import "ContentCellWithAvatar.h"
#import "ContentSeparatorCell.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeSeparatorTransparent,
    CellTypeSeparatorGray,
    CellTypeAvatar,
    CellTypeNameImmutable,
    CellTypeNameEditable,
    CellTypeStatusMessageImmutable,
    CellTypeStatusMessageEditable,
    CellTypeToxId,
};

@interface ProfileViewController () <ContentCellWithTitleImmutableDelegate,
                                     ContentCellWithTitleEditableDelegate,
                                     ContentCellWithAvatarDelegate,
                                     UIImagePickerControllerDelegate,
                                     UINavigationControllerDelegate>

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
                    @(CellTypeNameImmutable),
                    @(CellTypeStatusMessageImmutable),
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
    [self.tableView registerClass:[ContentCellWithTitleImmutable class]
           forCellReuseIdentifier:[ContentCellWithTitleImmutable reuseIdentifier]];
    [self.tableView registerClass:[ContentCellWithTitleEditable class]
           forCellReuseIdentifier:[ContentCellWithTitleEditable reuseIdentifier]];
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
        case CellTypeNameImmutable:
            return [self cellWithNameAtIndexPath:indexPath editable:NO];
        case CellTypeNameEditable:
            return [self cellWithNameAtIndexPath:indexPath editable:YES];
        case CellTypeStatusMessageImmutable:
            return [self cellWithStatusMessageAtIndexPath:indexPath editable:NO];
        case CellTypeStatusMessageEditable:
            return [self cellWithStatusMessageAtIndexPath:indexPath editable:YES];
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

#pragma mark -  ContentCellWithTitleBasicDelegate

- (void)contentCellWithTitleBasicDidPressButton:(ContentCellWithTitleBasic *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeToxId) {
        [self presentViewController:[[QRViewerController alloc] initWithToxId:cell.mainText] animated:YES completion:nil];
    }
}

#pragma mark -  ContentCellWithTitleImmutableDelegate

- (void)contentCellWithTitleImmutableEditButtonPressed:(ContentCellWithTitleImmutable *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CellType type = [self cellTypeForIndexPath:indexPath];

    NSMutableArray *arrayToChange = self.tableStructure[indexPath.section];

    if (type == CellTypeNameImmutable) {
        NSUInteger index = [arrayToChange indexOfObject:@(CellTypeNameImmutable)];
        [arrayToChange replaceObjectAtIndex:index withObject:@(CellTypeNameEditable)];
    }
    else if (type == CellTypeStatusMessageImmutable) {
        NSUInteger index = [arrayToChange indexOfObject:@(CellTypeStatusMessageImmutable)];
        [arrayToChange replaceObjectAtIndex:index withObject:@(CellTypeStatusMessageEditable)];
    }

    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    ContentCellWithTitleEditable *editableCell = (ContentCellWithTitleEditable *)
                                                 [self.tableView cellForRowAtIndexPath:indexPath];
    [editableCell startEditing];
}

#pragma mark -  ContentCellWithTitleEditableDelegate

- (void)contentCellWithTitleEditableDidBeginEditing:(ContentCellWithTitleEditable *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)contentCellWithTitleEditableDidEndEditing:(ContentCellWithTitleEditable *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CellType type = [self cellTypeForIndexPath:indexPath];

    NSMutableArray *arrayToChange = self.tableStructure[indexPath.section];

    if (type == CellTypeNameEditable) {
        [[AppContext sharedContext].profileManager.toxManager.user setUserName:cell.mainText error:nil];

        NSUInteger index = [arrayToChange indexOfObject:@(CellTypeNameEditable)];
        [arrayToChange replaceObjectAtIndex:index withObject:@(CellTypeNameImmutable)];

        // FIXME avatar
        // if (! [[ToxManager sharedInstance] userHasAvatar]) {
        [self reloadAvatarCell];
        // }
    }
    else if (type == CellTypeStatusMessageEditable) {
        [[AppContext sharedContext].profileManager.toxManager.user setUserStatusMessage:cell.mainText error:nil];

        NSUInteger index = [arrayToChange indexOfObject:@(CellTypeStatusMessageEditable)];
        [arrayToChange replaceObjectAtIndex:index withObject:@(CellTypeStatusMessageImmutable)];
    }

    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)contentCellWithTitleEditableWantsToResize:(ContentCellWithTitleEditable *)cell
{
    // This forces tableView to nicely animate change of cell's frame without reloading it.
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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

    [self reloadAvatarCell];
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

- (ContentCellWithTitleBasic *)cellWithNameAtIndexPath:(NSIndexPath *)indexPath editable:(BOOL)editable
{
    NSString *identifier = editable ?
                           [ContentCellWithTitleEditable reuseIdentifier] :
                           [ContentCellWithTitleImmutable reuseIdentifier];

    ContentCellWithTitleBasic *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"Name", @"Profile");
    cell.buttonTitle = nil;
    cell.mainText = [AppContext sharedContext].profileManager.toxManager.user.userName;

    if (editable) {
        ContentCellWithTitleEditable *eCell = (ContentCellWithTitleEditable *)cell;
        eCell.maxMainTextLength = kOCTToxMaxNameLength;
    }
    else {
        ContentCellWithTitleImmutable *iCell = (ContentCellWithTitleImmutable *)cell;
        iCell.showEditButton = YES;
    }

    return cell;
}

- (ContentCellWithTitleBasic *)cellWithStatusMessageAtIndexPath:(NSIndexPath *)indexPath editable:(BOOL)editable
{
    NSString *identifier = editable ?
                           [ContentCellWithTitleEditable reuseIdentifier] :
                           [ContentCellWithTitleImmutable reuseIdentifier];

    ContentCellWithTitleBasic *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"Status Message", @"Profile");
    cell.buttonTitle = nil;
    cell.mainText = [AppContext sharedContext].profileManager.toxManager.user.userStatusMessage;

    if (editable) {
        ContentCellWithTitleEditable *eCell = (ContentCellWithTitleEditable *)cell;
        eCell.maxMainTextLength = kOCTToxMaxStatusMessageLength;
    }
    else {
        ContentCellWithTitleImmutable *iCell = (ContentCellWithTitleImmutable *)cell;
        iCell.showEditButton = YES;
    }

    return cell;
}

- (ContentCellWithTitleImmutable *)cellWithToxIdAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ContentCellWithTitleImmutable reuseIdentifier];
    ContentCellWithTitleImmutable *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"My Tox ID", @"Profile");
    cell.buttonTitle = NSLocalizedString(@"Show QR", @"Profile");
    cell.mainText = [AppContext sharedContext].profileManager.toxManager.user.userAddress;
    cell.showEditButton = NO;

    return cell;
}

- (void)reloadAvatarCell
{
    NSIndexPath *path = [self indexPathForCellType:CellTypeAvatar];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

@end
