//
//  SettingsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "SettingsViewController.h"
#import "ToxManager.h"
#import "QRViewerController.h"
#import "UIViewController+Utilities.h"
#import "UIView+Utilities.h"
#import "AppDelegate.h"
#import "MFMailComposeViewController+BlocksKit.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "DDFileLogger.h"
#import "UITableViewCell+Utilities.h"
#import "AvatarManager.h"
#import "CellWithNameStatusAvatar.h"
#import "CellWithToxId.h"
#import "CellWithColorscheme.h"
#import "CellWithSwitch.h"
#import "ProfilesViewController.h"
#import "ProfileManager.h"
#import "UserInfoManager.h"

typedef NS_ENUM(NSUInteger, CellType) {
    CellTypeNameStatusAvatar,
    CellTypeToxId,
    CellTypeColorscheme,
    CellTypeFeedback,
    CellTypeTitleNotifications,
    CellTypeShowMessageInLocalNotification,
    CellTypeProfile,
    CellTypeChatBackgroundImage,
    CellTypeChatBackgroundBlured
};

static NSString *const kProfileReuseIdentifier = @"kProfileReuseIdentifier";
static NSString *const kFeedbackReuseIdentifier = @"kFeedbackReuseIdentifier";

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate,
    SettingsNameStatusAvatarCellDelegate, CellWithToxIdDelegate, CellWithColorschemeDelegate,
    CellWithSwitchDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *tableStructure;

@end

@implementation SettingsViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings");

        self.tableStructure = @[
            @[
                @(CellTypeNameStatusAvatar),
            ],
            @[
                @(CellTypeToxId),
            ],
            @[
                @(CellTypeColorscheme),
                @(CellTypeChatBackgroundImage),
                @(CellTypeChatBackgroundBlured)
            ],
            @[
                @(CellTypeProfile),
            ],
            @[
                @(CellTypeTitleNotifications),
                @(CellTypeShowMessageInLocalNotification),
            ],
            @[
                @(CellTypeFeedback),
            ],
        ];
    }

    return self;
}

- (void)loadView
{
    [self loadWhiteView];
    [self setupNavBarAppearance];
    [self createTableView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  UITableViewDataSource

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
    else if (type == CellTypeChatBackgroundImage) {
        return [self chatBackgroundImageCellAtIndexPath:indexPath];
    }
    else if (type == CellTypeChatBackgroundBlured) {
        return [self cellWithSwitchAtIndexPath:indexPath withType:CellTypeChatBackgroundBlured];
    }
    else if (type == CellTypeTitleNotifications) {
        return [self cellWithTitleAtIndexPath:indexPath withType:CellTypeTitleNotifications];
    }
    else if (type == CellTypeShowMessageInLocalNotification) {
        return [self cellWithSwitchAtIndexPath:indexPath withType:CellTypeShowMessageInLocalNotification];
    }
    else if (type == CellTypeProfile) {
        return [self profileCellAtIndexPath:indexPath];
    }
    else if (type == CellTypeFeedback) {
        return [self feedbackCellAtIndexPath:indexPath];
    }

    return [UITableViewCell new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableStructure.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *subArray = self.tableStructure[section];
    return subArray.count;
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
             type == CellTypeProfile ||
             type == CellTypeFeedback ||
             type == CellTypeChatBackgroundImage ||
             type == CellTypeChatBackgroundBlured)
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 20.0 : 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0;
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

    if ([[ToxManager sharedInstance] userHasAvatar]) {
        [sheet bk_setDestructiveButtonWithTitle:NSLocalizedString(@"Delete", @"Settings") handler:^{
            [[ToxManager sharedInstance] updateAvatar:nil];

            NSIndexPath *path = [weakSelf indexPathForCellType:CellTypeNameStatusAvatar];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }

    [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Settings") handler:nil];

    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)cellWithNameStatusAvatar:(CellWithNameStatusAvatar *)cell nameChangedTo:(NSString *)newName
{
    [ToxManager sharedInstance].userName = newName;

    if (! [[ToxManager sharedInstance] userHasAvatar]) {
        NSIndexPath *path = [self indexPathForCellType:CellTypeNameStatusAvatar];
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)cellWithNameStatusAvatar:(CellWithNameStatusAvatar *)cell
          statusMessageChangedTo:(NSString *)newStatusMessage
{
    [ToxManager sharedInstance].userStatusMessage = newStatusMessage;
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
    [AppearanceManager changeColorschemeTo:scheme];

    [self recreateControllers];
}



#pragma mark -  CellWithSwitchDelegate

- (void)cellWithSwitchStateChanged:(CellWithSwitch *)cell
{
    __weak typeof (self) weakSelf = self;
    
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    CellType cellType = [self cellTypeForIndexPath:cellIndexPath];
    
    if (cellType == CellTypeShowMessageInLocalNotification) {
        [UserInfoManager sharedInstance].uShowMessageInLocalNotification = @(cell.on);
    }
    else if (cellType == CellTypeChatBackgroundBlured) {
        [UserInfoManager sharedInstance].uChatBackgroundImageBlurEnable = @(cell.on);
        [self.view setUserInteractionEnabled:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakSelf recreateControllers];
            [weakSelf.view setUserInteractionEnabled:YES];
        });
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

    [[ToxManager sharedInstance] updateAvatar:image];

    NSIndexPath *path = [self indexPathForCellType:CellTypeNameStatusAvatar];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -  Private

- (void)createTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.tableView registerClass:[CellWithNameStatusAvatar class]
           forCellReuseIdentifier:[CellWithNameStatusAvatar reuseIdentifier]];

    [self.tableView registerClass:[CellWithToxId class] forCellReuseIdentifier:[CellWithToxId reuseIdentifier]];

    [self.tableView registerClass:[CellWithColorscheme class]
           forCellReuseIdentifier:[CellWithColorscheme reuseIdentifier]];

    [self.tableView registerClass:[CellWithSwitch class] forCellReuseIdentifier:[CellWithSwitch reuseIdentifier]];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kProfileReuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFeedbackReuseIdentifier];

    [self.view addSubview:self.tableView];
}

- (void)adjustSubviews
{
    self.tableView.frame = self.view.bounds;
}

- (void)showMailControllerWithLogs:(BOOL)withLogs
{
    MFMailComposeViewController *vc = [MFMailComposeViewController new];
    vc.navigationBar.tintColor = [AppearanceManager textMainColor];
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

- (NSIndexPath *)indexPathForCellType:(CellType)type
{
    for (NSUInteger section = 0; section < self.tableStructure.count; section++) {
        NSArray *subArray = self.tableStructure[section];

        for (NSUInteger row = 0; row < subArray.count; row++) {
            NSNumber *number = subArray[row];

            if (number.unsignedIntegerValue == type) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }

    return nil;
}

- (CellType)cellTypeForIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *number = self.tableStructure[indexPath.section][indexPath.row];
    return number.unsignedIntegerValue;
}

- (CellWithNameStatusAvatar *)cellWithNameStatusAvatarAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [CellWithNameStatusAvatar reuseIdentifier];

    CellWithNameStatusAvatar *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier
                                                                          forIndexPath:indexPath];

    NSString *userName = [ToxManager sharedInstance].userName;

    UIImage *avatar = [[ToxManager sharedInstance] userAvatar] ?:
        [AvatarManager avatarFromString:userName side:[CellWithNameStatusAvatar avatarHeight]];

    cell.delegate = self;
    cell.avatarImage = avatar;
    cell.name = userName;
    cell.statusMessage = [ToxManager sharedInstance].userStatusMessage;
    cell.maxNameLength = TOX_MAX_NAME_LENGTH;
    cell.maxStatusMessageLength = TOX_MAX_STATUSMESSAGE_LENGTH;

    [cell redraw];

    return cell;
}

- (CellWithToxId *)cellWithToxIdAtIndexPath:(NSIndexPath *)indexPath
{
    CellWithToxId *cell = [self.tableView dequeueReusableCellWithIdentifier:[CellWithToxId reuseIdentifier]
                                                               forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"My Tox ID", @"Settings");
    cell.toxId = [ToxManager sharedInstance].toxId;

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

- (CellWithSwitch *)cellWithSwitchAtIndexPath:(NSIndexPath *)indexPath withType:(CellType)type
{
    CellWithSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:[CellWithSwitch reuseIdentifier]
                                                                forIndexPath:indexPath];
    cell.delegate = self;
    
    if (type == CellTypeShowMessageInLocalNotification) {
        cell.title = NSLocalizedString(@"Message preview", @"Settings");
        cell.on = [UserInfoManager sharedInstance].uShowMessageInLocalNotification.boolValue;
    }
    else if (type == CellTypeChatBackgroundBlured) {
        cell.title = NSLocalizedString(@"Chat background blur", @"Settings");
        cell.on = [UserInfoManager sharedInstance].uChatBackgroundImageBlurEnable.boolValue;
    }
    
    return cell;
}

- (UITableViewCell *)profileCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kProfileReuseIdentifier
                                                                 forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",
        NSLocalizedString(@"Profile", @"Settings"),
        [ProfileManager sharedInstance].currentProfile.name];

    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [AppearanceManager textMainColor];

    return cell;
}

- (UITableViewCell *)feedbackCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kFeedbackReuseIdentifier
                                                                 forIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(@"Feedback", @"Settings");
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [AppearanceManager textMainColor];

    return cell;
}

- (UITableViewCell *)chatBackgroundImageCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kFeedbackReuseIdentifier
                                                                 forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = NSLocalizedString(@"Chat background image", @"Settings");

    return cell;
}

#pragma mark - Utilities

- (void)recreateControllers
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate recreateControllersAndShow:AppDelegateTabIndexSettings];
}

@end