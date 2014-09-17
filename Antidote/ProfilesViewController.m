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
#import "CoreDataManager+Profile.h"
#import "UIAlertView+BlocksKit.h"
#import "ProfileManager.h"
#import "AppDelegate.h"
#import "UIActionSheet+BlocksKit.h"

@interface ProfilesViewController () <UITableViewDataSource, UITableViewDelegate,
    NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    [CoreDataManager fetchedControllerWithDelegate:self completionQueue:dispatch_get_main_queue() completionBlock:
        ^(NSFetchedResultsController *controller)
    {
        self.fetchedResultsController = controller;

        [self.tableView reloadData];
    }];
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

        [[ProfileManager sharedInstance] addNewProfileWithName:name];
    }];

    [view bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profiles") handler:nil];

    [view show];
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CDProfile *profile = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[UITableViewCell reuseIdentifier]
                                                                 forIndexPath:indexPath];
    cell.textLabel.text = profile.name;

    if ([profile isEqual:[ProfileManager sharedInstance].currentProfile]) {
        cell.textLabel.font = [AppearanceManager fontHelveticaNeueBoldWithSize:16.0];
    }
    else {
        cell.textLabel.font = [AppearanceManager fontHelveticaNeueWithSize:16.0];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> info = self.fetchedResultsController.sections[section];

    return info.numberOfObjects;
}

#pragma mark -  UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CDProfile *profile = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([profile isEqual:[ProfileManager sharedInstance].currentProfile]) {
        return;
    }

    UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:nil];

    [sheet bk_addButtonWithTitle:NSLocalizedString(@"Select", @"Profiles") handler:^{
        [self selectProfile:profile];
    }];

    [sheet bk_addButtonWithTitle:NSLocalizedString(@"Rename", @"Profiles") handler:^{
        [self renameProfile:profile];
    }];

    [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profiles") handler:nil];

    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)  tableView:(UITableView *)tableView
 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
  forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CDProfile *profile = [self.fetchedResultsController objectAtIndexPath:indexPath];

        if ([profile isEqual:[ProfileManager sharedInstance].currentProfile]) {
            tableView.editing = NO;

            NSString *title = NSLocalizedString(@"Cannot delete active profile", @"Profiles");
            UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:title];

            [alert bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profiles") handler:nil];

            [alert show];

            return;
        }

        NSString *title = [NSString stringWithFormat:
            NSLocalizedString(@"Delete profile %@?", @"Profiles"), profile.name];

        NSString *message = NSLocalizedString(@"This operation cannot be undone", @"Profiles");
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:title message:message];

        [alert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Profiles") handler:^{
            [[ProfileManager sharedInstance] deleteProfile:profile];
        }];

        [alert bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Profiles") handler:nil];

        [alert show];
    }
}

#pragma mark -  NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeMove) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeUpdate) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
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

- (void)selectProfile:(CDProfile *)profile
{
    [[ProfileManager sharedInstance] switchToProfile:profile];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate recreateControllersAndShow:AppDelegateTabIndexSettings withBlock:^(UINavigationController *nav) {
                 [nav pushViewController:[ProfilesViewController new] animated:NO];
    }];
}

- (void)renameProfile:(CDProfile *)profile
{
    NSString *title = NSLocalizedString(@"New profile name", @"Profiles");
    UIAlertView *view = [UIAlertView bk_alertViewWithTitle:title];
    view.alertViewStyle = UIAlertViewStylePlainTextInput;
    [view textFieldAtIndex:0].text = profile.name;

    [view bk_addButtonWithTitle:NSLocalizedString(@"OK", @"Profiles") handler:^{
        NSString *name = [view textFieldAtIndex:0].text;

        [[ProfileManager sharedInstance] renameProfile:profile to:name];
    }];

    [view bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Profiles") handler:nil];

    [view show];
}

@end
