//
//  CallNavigationControllerViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/7/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "CallNavigationViewController.h"

#import "Masonry.h"
#import "OCTCall.h"
#import "ProfileManager.h"
#import "OCTSubmanagerCalls.h"
#import "OCTManager.h"
#import "Helper.h"
#import "AbstractCallViewController.h"
#import "ActiveCallViewController.h"
#import "DialingCallViewController.h"
#import "RingingCallViewController.h"

@interface CallNavigationViewController () <RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic) UIView *otherIncomingCallView;

@property (strong, nonatomic) RBQFetchedResultsController *allCallsController;

@end

@implementation CallNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    self.navigationBarHidden = YES;

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.view.bounds;

    [self.view insertSubview:visualEffectView atIndex:0];

    [visualEffectView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    _allCallsController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall delegate:self];
}

#pragma mark - Call Handling

- (void)switchToCall:(OCTCall *)call fromAbstractViewController:(AbstractCallViewController *)viewController
{
    AbstractCallViewController *viewControllerToPush = [self createViewControllerFromCall:call];
    viewControllerToPush.modalInPopover = YES;
    viewControllerToPush.modalPresentationStyle = UIModalPresentationOverFullScreen;

    [self popToRootViewControllerAnimated:NO];
    [self pushViewController:viewControllerToPush animated:YES];
}

#pragma mark - RBQFetchedResultsControllerDelegate

- (void) controller:(RBQFetchedResultsController *)controller
    didChangeObject:(RBQSafeRealmObject *)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath;
{

    if (type == NSFetchedResultsChangeDelete) {
        if ([self.allCallsController.fetchedObjects count] == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }

    if (type == NSFetchedResultsChangeInsert) {
        OCTCall *newCall = [self.allCallsController objectAtIndexPath:indexPath];

        if (newCall.status == OCTCallStatusRinging) {
            [self notifyTopViewControllerOfCall:newCall];
        }
    }
}

#pragma mark - Private

- (AbstractCallViewController *)createViewControllerFromCall:(OCTCall *)call
{
    AbstractCallViewController *viewController;

    OCTSubmanagerCalls *manager = [AppContext sharedContext].profileManager.toxManager.calls;

    switch (call.status) {
        case OCTCallStatusActive:
            viewController = [[ActiveCallViewController alloc] initWithCall:call submanagerCalls:manager];
            break;
        case OCTCallStatusRinging:
            viewController = [[RingingCallViewController alloc] initWithCall:call submanagerCalls:manager];
        case OCTCallStatusDialing:
            NSAssert(NO, @"Ability to make another call while in another call is not available yet");
            break;
        case OCTCallStatusPaused:
            NSAssert(NO, @"You must resume the call before switching");
            break;
    }

    return viewController;
}

- (void)notifyTopViewControllerOfCall:(OCTCall *)call
{
    AbstractCallViewController *topVC = (AbstractCallViewController *)[self topViewController];

    [topVC displayNotificationOfNewCall:call];
}
@end
