//
//  ProfilesListViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 17.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ProfilesListViewController.h"
#import "UIViewController+Utilities.h"
#import "UITableViewCell+Utilities.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "ProfileManager.h"
#import "AppearanceManager.h"
#import "TabBarViewController.h"
#import "ErrorHandler.h"

@interface ProfilesListViewController () <UITableViewDataSource, UITableViewDelegate,
                                          UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation ProfilesListViewController

#pragma mark -  Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                       target:self
                                                                       action:@selector(addButtonPressed)];
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

#pragma mark -  Actions

- (void)addButtonPressed
{
    NSString *title = NSLocalizedString(@"New profile name", @"Profiles List");
    UIAlertView *view = [UIAlertView bk_alertViewWithTitle:title];
    view.alertViewStyle = UIAlertViewStylePlainTextInput;

    [view bk_addButtonWithTitle:NSLocalizedString(@"OK", @"Profiles List") handler:^{
        NSString *name = [view textFieldAtIndex:0].text;

        [self selectProfile:name];
    }];

    [view bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profiles List") handler:nil];

    [view show];
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[UITableViewCell reuseIdentifier]
                                                                 forIndexPath:indexPath];
    cell.textLabel.text = [self nameAtIndexPath:indexPath];

    if ([self isCurrentProfile:cell.textLabel.text]) {
        cell.textLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:16.0];
    }
    else {
        cell.textLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:16.0];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AppContext sharedContext].profileManager.allProfiles.count;
}

#pragma mark -  UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *name = [self nameAtIndexPath:indexPath];

    UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:nil];

    if (! [self isCurrentProfile:name]) {
        [sheet bk_addButtonWithTitle:NSLocalizedString(@"Select", @"Profiles List") handler:^{
            [self selectProfile:name];
        }];
    }

    [sheet bk_addButtonWithTitle:NSLocalizedString(@"Rename", @"Profiles List") handler:^{
        [self renameProfile:name];
    }];

    [sheet bk_addButtonWithTitle:NSLocalizedString(@"Export", @"Profiles List") handler:^{
        [self exportProfile:name];
    }];

    // FIXME add delete option

    [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profiles List") handler:nil];

    [sheet showInView:self.view];
}

- (void)     tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *name = [self nameAtIndexPath:indexPath];

        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Delete profile %@?", @"Profiles List"), name];

        NSString *message = NSLocalizedString(@"This operation cannot be undone", @"Profiles List");
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:title message:message];

        [alert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Profiles List") handler:^{
            BOOL isCurrent = [self isCurrentProfile:name];
            NSError *error;

            if (! [[AppContext sharedContext].profileManager deleteProfileWithName:name error:&error]) {
                [[AppContext sharedContext].errorHandler handleError:error type:ErrorHandlerTypeDeleteProfile];
                return;
            }

            isCurrent ?  [self recreateControllers] : [self.tableView reloadData];
        }];

        [alert bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Profiles List") handler:nil];

        [alert show];
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

- (void)createTableView
{
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell reuseIdentifier]];

    [self.view addSubview:self.tableView];
}

- (void)adjustSubviews
{
    self.tableView.frame = self.view.bounds;
}

- (void)selectProfile:(NSString *)name
{
    [[AppContext sharedContext].profileManager switchToProfileWithName:name];

    [self recreateControllers];
}

- (void)recreateControllers
{
    [[AppContext sharedContext] recreateTabBarController];

    TabBarViewControllerIndex index = TabBarViewControllerIndexSettings;
    [AppContext sharedContext].tabBarController.selectedIndex = index;

    UINavigationController *navCon = [[AppContext sharedContext].tabBarController navigationControllerForIndex:index];
    [navCon pushViewController:[ProfilesListViewController new] animated:NO];
}

- (void)renameProfile:(NSString *)name
{
    NSString *title = NSLocalizedString(@"New profile name", @"Profiles List");
    UIAlertView *view = [UIAlertView bk_alertViewWithTitle:title];
    view.alertViewStyle = UIAlertViewStylePlainTextInput;
    [view textFieldAtIndex:0].text = name;

    [view bk_addButtonWithTitle:NSLocalizedString(@"OK", @"Profiles List") handler:^{
        NSString *nName = [view textFieldAtIndex:0].text;

        if (! nName.length) {
            return;
        }

        NSError *error;

        if (! [[AppContext sharedContext].profileManager renameProfileWithName:name toName:nName error:&error]) {
            [[AppContext sharedContext].errorHandler handleError:error type:ErrorHandlerTypeRenameProfile];
            return;
        }

        [self.tableView reloadData];
    }];

    [view bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profiles List") handler:nil];

    [view show];
}

- (void)exportProfile:(NSString *)name
{
    NSError *error;
    NSURL *url = [[AppContext sharedContext].profileManager exportProfileWithName:name error:&error];

    if (! url) {
        [[AppContext sharedContext].errorHandler handleError:error type:ErrorHandlerTypeExportProfile];
        return;
    }

    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    self.documentInteractionController.delegate = self;
    self.documentInteractionController.name = [url lastPathComponent];

    [self.documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
}

- (NSString *)nameAtIndexPath:(NSIndexPath *)indexPath
{
    return [AppContext sharedContext].profileManager.allProfiles[indexPath.row];
}

- (BOOL)isCurrentProfile:(NSString *)name
{
    NSParameterAssert(name);

    NSString *currentName = [AppContext sharedContext].profileManager.currentProfileName;

    return [name isEqualToString:currentName];
}

@end
