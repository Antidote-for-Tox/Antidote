//
//  CallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/1/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "CallViewController.h"
#import "Masonry.h"
#import "Helper.h"
#import "OCTCall.h"

NSString *const kCallViewControllerUserIdentifier = @"callViewController";

@interface CallViewController () <RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic, readwrite) OCTChat *chat;
@property (strong, nonatomic) OCTCall *call;
@property (strong, nonatomic) RBQFetchedResultsController *callController;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *cancelCallButton;
@property (strong, nonatomic) UILabel *timerLabel;

@end

@implementation CallViewController

#pragma mark - Life cycle
- (instancetype)initWithChat:(OCTChat *)chat
{
    self = [super init];
    if (! self) {
        return nil;
    }

    _chat = chat;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chat == %@", chat];
    _callController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall predicate:predicate delegate:self];
    _callController.delegate = self;

    _call = [_callController fetchedObjects].firstObject;
    if (! _call) {
        return nil;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.opaque = YES;

    [self setupBlurredView];
    [self createNameLabel];

    [self createEndCallButton];
    [self createCallTimer];

    [self layoutSubviews];
}

#pragma mark -  RBQFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(RBQFetchedResultsController *)controller
{}

- (void)controller:(RBQFetchedResultsController *)controller didChangeObject:(RBQSafeRealmObject *)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{}

- (void)controller:(RBQFetchedResultsController *)controller didChangeSection:(RBQFetchedResultsSectionInfo *)section atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{}

- (void)controllerDidChangeContent:(RBQFetchedResultsController *)controller
{
    self.call = [self.callController fetchedObjects].firstObject;

    self.timerLabel.text = [self convertToTimeFromInterval:self.call.callDuration];
    [self.timerLabel setNeedsDisplay];
}
#pragma mark - Private

- (void)setupBlurredView
{
    self.view.backgroundColor = [UIColor clearColor];

    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    darkView.backgroundColor = [UIColor blackColor];
    darkView.alpha = 0.5;

    [self.view addSubview:darkView];

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.view.bounds;

    [self.view addSubview:visualEffectView];
}

- (void)createNameLabel
{
    if (self.call.chat.friends.count == 1) {
        OCTFriend *friend = self.call.chat.friends.firstObject;

        CGRect labelFrame = CGRectMake(0, 0, 200, 200);
        self.nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
        self.nameLabel.text = friend.nickname;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.nameLabel sizeToFit];

        [self.view addSubview:self.nameLabel];
    }
}
- (void)createEndCallButton
{
    CGRect frame = CGRectMake(0, 0, 400, 100);
    self.cancelCallButton = [[UIButton alloc] initWithFrame:frame];
    self.cancelCallButton.backgroundColor = [UIColor redColor];
    [self.cancelCallButton setImage:[UIImage imageWithContentsOfFile:@"phone"] forState:UIControlStateNormal];
    [self.cancelCallButton addTarget:self action:@selector(endCall) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.cancelCallButton];
}

- (void)createCallTimer
{
    self.timerLabel = [[UILabel alloc] init];
    self.timerLabel.textColor = [UIColor whiteColor];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;

    [self.view addSubview:self.timerLabel];
}

- (void)layoutSubviews
{
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(50);
        make.left.equalTo(self.view.mas_left).with.offset(50);
        make.right.equalTo(self.view.mas_right).with.offset(-50);
        make.height.equalTo(30);
    }];

    [self.cancelCallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-50);
        make.centerX.equalTo(self.view.mas_centerX);
        make.left.equalTo(self.view.mas_left).with.offset(50);
        make.right.equalTo(self.view.mas_right).with.offset(-50);
    }];

    [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(20);
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.nameLabel.mas_right);
        make.centerX.equalTo(self.nameLabel.centerX);
    }];
}

- (NSString *)convertToTimeFromInterval:(NSTimeInterval)interval
{
    int minutes = (int)interval / 60;
    int seconds = interval - (minutes * 60);

    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)endCall
{
    // do animation stuff
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
