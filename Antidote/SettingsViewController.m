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
#import "DDFileLogger.h"
#import "UITableViewCell+Utilities.h"
#import "AvatarFactory.h"
#import "CellWithNameStatusAvatar.h"
#import "CellWithToxId.h"
#import "CellWithColorscheme.h"
#import "ProfilesViewController.h"

typedef NS_ENUM(NSUInteger, CellType) {
    CellTypeNameStatusAvatar,
    CellTypeToxId,
    CellTypeColorscheme,
    CellTypeFeedback,
    CellTypeProfile,
    __CellTypeTotalCount,
};

static NSString *const kProfileReuseIdentifier = @"kProfileReuseIdentifier";
static NSString *const kFeedbackReuseIdentifier = @"kFeedbackReuseIdentifier";

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate,
    SettingsNameStatusAvatarCellDelegate, CellWithToxIdDelegate, CellWithColorschemeDelegate>

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
                @(CellTypeColorscheme),
            ],
            @[
                @(CellTypeProfile),
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
    else if (type == CellTypeProfile) {
        return [self profileCellAtIndexPath:indexPath];
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
    else if (type == CellTypeProfile) {
        return 44.0;
    }
    else if (type == CellTypeFeedback) {
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

- (void)cellWithNameStatusAvatar:(CellWithNameStatusAvatar *)cell nameChangedTo:(NSString *)newName
{
    [ToxManager sharedInstance].userName = newName;
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

#pragma mark -  CellWithColorscheme

- (void)cellWithColorscheme:(CellWithColorscheme *)cell didSelectScheme:(AppearanceManagerColorscheme)scheme
{
    [AppearanceManager changeColorschemeTo:scheme];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [delegate recreateControllersAndShow:AppDelegateTabIndexSettings];
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

    cell.delegate = self;
    cell.avatarImage = [AvatarFactory avatarFromString:userName side:[CellWithNameStatusAvatar avatarHeight]];
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

- (UITableViewCell *)profileCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kProfileReuseIdentifier
                                                                 forIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(@"Profile", @"Settings");
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

@end
