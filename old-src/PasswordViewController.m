//
//  PasswordViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 22/09/15.
//  Copyright © 2015 dvor. All rights reserved.
//

#import <BlocksKit/UIBarButtonItem+BlocksKit.h>

#import <objcTox/OCTManager.h>
#import <objcTox/OCTManagerConfiguration.h>

#import "PasswordViewController.h"
#import "ContentCellSimple.h"
#import "ContentSeparatorCell.h"
#import "CellWithSwitch.h"
#import "UITableViewCell+Utilities.h"
#import "RunningContext.h"
#import "WizardViewController.h"
#import "AppearanceManager.h"

typedef NS_ENUM(NSUInteger, CellType) {
    CellTypeSeparatorTransparent,
    CellTypeUseSwitch,
    CellTypeChangePassword,
};

@interface PasswordViewController () <CellWithSwitchDelegate>

@end

@implementation PasswordViewController

#pragma mark -  Lifecycle

- (id)init
{
    return [super initWithTitle:NSLocalizedString(@"Password", @"PasswordViewController") tableStyle:UITableViewStylePlain tableStructure:@[
                @[]
                ,
            ]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateTableStructure];
}

#pragma mark -  Override

- (void)configureTableView
{
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[ContentSeparatorCell class] forCellReuseIdentifier:[ContentSeparatorCell reuseIdentifier]];
    [self.tableView registerClass:[ContentCellSimple class] forCellReuseIdentifier:[ContentCellSimple reuseIdentifier]];
    [self.tableView registerClass:[CellWithSwitch class] forCellReuseIdentifier:[CellWithSwitch reuseIdentifier]];
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    switch (type) {
        case CellTypeSeparatorTransparent:
            return [self separatorCellAtIndexPath:indexPath isGray:NO];
        case CellTypeUseSwitch:
            return [self useSwitchCellAtIndexPath:indexPath];
        case CellTypeChangePassword:
            return [self changePasswordCellAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CellType type = [self cellTypeForIndexPath:indexPath];

    if (type == CellTypeChangePassword) {
        [self startChangePasswordProcess];
    }
}

#pragma mark -  CellWithSwitchDelegate

- (void)cellWithSwitchStateChanged:(CellWithSwitch *)cell
{
    if (cell.on) {
        [self startChangePasswordProcess];
    }
    else {
        [self startRemovePasswordProcess];
    }
}

#pragma mark -  Private

- (void)updateTableStructure
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[
                                 @(CellTypeSeparatorTransparent),
                                 @(CellTypeUseSwitch),
                                 @(CellTypeSeparatorTransparent),
                             ]];

    if ([self existingPassword]) {
        [array addObject:@(CellTypeChangePassword)];
    }

    self.tableStructure[0] = array;

    [self.tableView reloadData];
}

- (ContentSeparatorCell *)separatorCellAtIndexPath:(NSIndexPath *)indexPath isGray:(BOOL)isGray
{
    ContentSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[ContentSeparatorCell reuseIdentifier]
                                                                      forIndexPath:indexPath];
    cell.showGraySeparator = isGray;

    if (! isGray) {
        [cell setHeight:1.0];
    }

    return cell;
}

- (CellWithSwitch *)useSwitchCellAtIndexPath:(NSIndexPath *)indexPath
{
    CellWithSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:[CellWithSwitch reuseIdentifier]
                                                                forIndexPath:indexPath];
    cell.delegate = self;

    cell.title = NSLocalizedString(@"Use password", @"Settings");
    cell.indentationWidth = 5.0;
    cell.indentationLevel = 1;
    cell.on = [self existingPassword] != nil;

    return cell;
}

- (ContentCellSimple *)changePasswordCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ContentCellSimple reuseIdentifier];
    ContentCellSimple *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell resetCell];

    cell.title = [self changePasswordString];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)startChangePasswordProcess
{
    WizardViewController *wizard;

    if ([self existingPassword]) {
        weakself;

        wizard = [self oldPasswordWizardWithSuccessBlock:^(WizardViewController *theController) {
            strongself;
            [theController.navigationController pushViewController:[self enterPasswordWizzard] animated:YES];
        }];

        wizard.textField.returnKeyType = UIReturnKeyNext;
    }
    else {
        wizard = [self enterPasswordWizzard];
    }

    [self presentViewController:wizard];
}

- (void)startRemovePasswordProcess
{
    weakself;
    WizardViewController *wizard = [self oldPasswordWizardWithSuccessBlock:^(WizardViewController *theController) {
        strongself;
        [self changePasswordTo:nil];
        [theController dismissViewControllerAnimated:YES completion:nil];
    }];

    wizard.textField.returnKeyType = UIReturnKeyDone;
    wizard.title = NSLocalizedString(@"Delete password", @"PasswordViewController");

    [self presentViewController:wizard];
}

- (void)presentViewController:(UIViewController *)controller
{
    WeakRef(controller);
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                   bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          handler:^(id sender) {
        StrongRef(controller);
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];

    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:controller];
    navCon.navigationBar.tintColor = [[AppContext sharedContext].appearance textMainColor];
    [self presentViewController:navCon animated:YES completion:nil];
}

- (WizardViewController *)oldPasswordWizardWithSuccessBlock:(void (^)(WizardViewController *theController))successBlock
{
    WizardViewController *controller = [self basicWizard];
    controller.textField.placeholder = NSLocalizedString(@"Old Password", @"PasswordViewController");

    controller.returnKeyPressedBlock = ^(WizardViewController *theController) {
        NSString *existing = [self existingPassword];
        NSString *entered = theController.textField.text;

        if ([existing isEqualToString:entered]) {
            successBlock(theController);
        }
        else {
            [self showErrorWithMessage:NSLocalizedString(@"Wrong password, please try again", @"PasswordViewController")];
        }
    };

    return controller;
}

- (WizardViewController *)enterPasswordWizzard
{
    WizardViewController *controller = [self basicWizard];
    controller.textField.placeholder = NSLocalizedString(@"New Password", @"PasswordViewController");
    controller.textField.returnKeyType = UIReturnKeyNext;

    controller.returnKeyPressedBlock = ^(WizardViewController *theController) {
        NSString *password = theController.textField.text;

        if (password.length) {
            [theController.navigationController pushViewController:[self repeatPasswordWizzardWithPassword:password]
                                                          animated:YES];
        }
        else {
            [self showErrorWithMessage:NSLocalizedString(@"Please enter password", @"PasswordViewController")];
        }
    };

    return controller;
}

- (WizardViewController *)repeatPasswordWizzardWithPassword:(NSString *)firstPassword
{
    WizardViewController *controller = [self basicWizard];
    controller.textField.placeholder = NSLocalizedString(@"Repeat Password", @"PasswordViewController");
    controller.textField.returnKeyType = UIReturnKeyDone;

    controller.returnKeyPressedBlock = ^(WizardViewController *theController) {
        NSString *secondPassword = theController.textField.text;

        if ([firstPassword isEqualToString:secondPassword]) {
            [self changePasswordTo:firstPassword];
            [theController dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self showErrorWithMessage:NSLocalizedString(@"Passwords don't match, please try again", @"PasswordViewController")];
        }
    };

    return controller;
}

- (WizardViewController *)basicWizard
{
    WizardViewController *controller = [WizardViewController new];
    controller.title = [self changePasswordString];
    controller.textField.secureTextEntry = YES;

    return controller;
}

- (NSString *)changePasswordString
{
    return NSLocalizedString(@"Change Password", @"PasswordViewController");
}

- (NSString *)existingPassword
{
    return [RunningContext context].toxManager.configuration.passphrase;
}

- (void)showErrorWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:nil
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"PasswordViewController")
                      otherButtonTitles:nil] show];
}

- (void)changePasswordTo:(NSString *)password
{
    [[RunningContext context].toxManager changePassphrase:password];
}

@end
