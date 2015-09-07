//
//  SettingsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>

#import "SettingsViewController.h"
#import "UIView+Utilities.h"
#import "AppDelegate.h"
#import "MFMailComposeViewController+BlocksKit.h"
#import "DDFileLogger.h"
#import "UITableViewCell+Utilities.h"
#import "CellWithColorscheme.h"
#import "CellWithSwitch.h"
#import "AdvancedSettingsViewController.h"
#import "UserDefaultsManager.h"
#import "TabBarViewController.h"
#import "AboutViewController.h"
#import "RunningContext.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeColorscheme,
    CellTypeFeedback,
    CellTypeTitleNotifications,
    CellTypeShowMessageInLocalNotification,
    CellTypeAdvancedSettings,
    CellTypeAbout,
};

static NSString *const kProfileReuseIdentifier = @"kProfileReuseIdentifier";
static NSString *const kFeedbackReuseIdentifier = @"kFeedbackReuseIdentifier";

@interface SettingsViewController () <CellWithColorschemeDelegate, CellWithSwitchDelegate>

@end

@implementation SettingsViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    return [super initWithTitle:NSLocalizedString(@"Settings", @"Settings") tableStyle:UITableViewStyleGrouped tableStructure:@[
                @[
                    @(CellTypeColorscheme),
                ],
                @[
                    @(CellTypeTitleNotifications),
                    @(CellTypeShowMessageInLocalNotification),
                ],
                @[
                    @(CellTypeAbout),
                    @(CellTypeAdvancedSettings),
                ],
                @[
                    @(CellTypeFeedback),
                ],
            ]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark -  Overridden methods

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[CellWithColorscheme class]
           forCellReuseIdentifier:[CellWithColorscheme reuseIdentifier]];

    [self.tableView registerClass:[CellWithSwitch class] forCellReuseIdentifier:[CellWithSwitch reuseIdentifier]];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kProfileReuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFeedbackReuseIdentifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeColorscheme) {
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
    else if (type == CellTypeAbout) {
        return [self cellWithArrowAtIndexPath:indexPath type:type];
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

    if (type == CellTypeColorscheme) {
        return [CellWithColorscheme height];
    }
    else if ((type == CellTypeTitleNotifications) ||
             (type == CellTypeShowMessageInLocalNotification) ||
             (type == CellTypeAdvancedSettings) ||
             (type == CellTypeAbout) ||
             (type == CellTypeFeedback) ) {
        return 44.0;
    }

    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeAdvancedSettings) {
        [self.navigationController pushViewController:[AdvancedSettingsViewController new] animated:YES];
    }
    else if (type == CellTypeAbout) {
        [self.navigationController pushViewController:[AboutViewController new] animated:YES];
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

        weakself;

        [alertView bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Settings") handler:^{
            strongself;
            [self showMailControllerWithLogs:NO];
        }];

        [alertView bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Settings") handler:^{
            strongself;
            [self showMailControllerWithLogs:YES];
        }];

        [alertView show];
    }
}

#pragma mark -  CellWithColorschemeDelegate

- (void)cellWithColorscheme:(CellWithColorscheme *)cell didSelectScheme:(AppearanceManagerColorscheme)scheme
{
    AppContext *context = [AppContext sharedContext];

    context.userDefaults.uCurrentColorscheme = @(scheme);
    [context recreateAppearance];

    [RunningContext context].tabBarController.selectedIndex = TabBarViewControllerIndexSettings;
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

#pragma mark -  Private

- (void)showMailControllerWithLogs:(BOOL)withLogs
{
    MFMailComposeViewController *vc = [MFMailComposeViewController new];
    vc.navigationBar.tintColor = [[AppContext sharedContext].appearance textMainColor];
    [vc setSubject:@"Feedback"];
    [vc setToRecipients:@[@"feedback@antidote.im"]];

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
    else if (type == CellTypeAbout) {
        cell.textLabel.text = NSLocalizedString(@"About", @"Settings");
    }

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
