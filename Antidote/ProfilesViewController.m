//
//  ProfilesViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 17.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ProfilesViewController.h"
#import "UIViewController+Utilities.h"
#import "UITableViewCell+Utilities.h"
#import "UIAlertView+BlocksKit.h"
#import "AppDelegate.h"
#import "UIActionSheet+BlocksKit.h"
#import "ProfileManager.h"
#import "AppearanceManager.h"

@interface ProfilesViewController () <UITableViewDataSource, UITableViewDelegate,
    UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;

// FIXME
// @property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation ProfilesViewController

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
    NSString *title = NSLocalizedString(@"New profile name", @"Profiles");
    UIAlertView *view = [UIAlertView bk_alertViewWithTitle:title];
    view.alertViewStyle = UIAlertViewStylePlainTextInput;

    [view bk_addButtonWithTitle:NSLocalizedString(@"OK", @"Profiles") handler:^{
        NSString *name = [view textFieldAtIndex:0].text;

        [self selectProfile:name];
    }];

    [view bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profiles") handler:nil];

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
        [sheet bk_addButtonWithTitle:NSLocalizedString(@"Select", @"Profiles") handler:^{
            [self selectProfile:name];
        }];
    }

    [sheet bk_addButtonWithTitle:NSLocalizedString(@"Rename", @"Profiles") handler:^{
        [self renameProfile:name];
    }];

    [sheet bk_addButtonWithTitle:NSLocalizedString(@"Export", @"Profiles") handler:^{
        [self exportProfile:name];
    }];

    //FIXME add delete option

    [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profiles") handler:nil];

    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)  tableView:(UITableView *)tableView
 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
  forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *name = [self nameAtIndexPath:indexPath];

        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Delete profile %@?", @"Profiles"), name];

        NSString *message = NSLocalizedString(@"This operation cannot be undone", @"Profiles");
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:title message:message];

        [alert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Profiles") handler:^{
            BOOL isCurrent = [self isCurrentProfile:name];
            [[AppContext sharedContext].profileManager deleteProfileWithName:name];

            isCurrent ?  [self recreateControllers] : [self.tableView reloadData];
        }];

        [alert bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Profiles") handler:nil];

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
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate recreateControllersAndShow:AppDelegateTabIndexSettings withBlock:^(UINavigationController *nav) {
         [nav pushViewController:[ProfilesViewController new] animated:NO];
    }];
}

- (void)renameProfile:(NSString *)name
{
    // FIXME
    // NSString *title = NSLocalizedString(@"New profile name", @"Profiles");
    // UIAlertView *view = [UIAlertView bk_alertViewWithTitle:title];
    // view.alertViewStyle = UIAlertViewStylePlainTextInput;
    // [view textFieldAtIndex:0].text = profile.name;

    // [view bk_addButtonWithTitle:NSLocalizedString(@"OK", @"Profiles") handler:^{
    //     NSString *name = [view textFieldAtIndex:0].text;

    //     [[ProfileManager sharedInstance] renameProfile:profile to:name];
    // }];

    // [view bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profiles") handler:nil];

    // [view show];
}

- (void)exportProfile:(NSString *)name
{
    // NSURL *url = [[ProfileManager sharedInstance] toxDataURLForProfile:profile];

    // self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    // self.documentInteractionController.delegate = self;
    // self.documentInteractionController.name = [url lastPathComponent];

    // [self.documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
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
