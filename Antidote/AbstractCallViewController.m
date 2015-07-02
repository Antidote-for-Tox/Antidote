//
//  AbstractCallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "AbstractCallViewController.h"

#import "Masonry.h"
#import "Helper.h"
#import "OCTCall.h"
#import "OCTChat.h"
#import "OCTSubmanagerCalls.h"

static const CGFloat kIndent = 50.0;

@interface AbstractCallViewController () <RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic) RBQFetchedResultsController *callController;
@property (strong, nonatomic, readwrite) OCTCall *call;
@property (strong, nonatomic, readwrite) UILabel *nameLabel;

@end

@implementation AbstractCallViewController

#pragma mark - Life cycle

- (instancetype)initWithCall:(OCTCall *)call submanagerCalls:(OCTSubmanagerCalls *)manager
{
    self = [super init];
    if (! self) {
        return nil;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@", call.uniqueIdentifier];
    _callController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall predicate:predicate delegate:self];
    _callController.delegate = self;

    _call = [[_callController fetchedObjects] firstObject];

    if (! _call) {
        return nil;
    }

    _manager = manager;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.opaque = YES;

    self.view.backgroundColor = [UIColor clearColor];

    [self setupBlurredView];
    [self createNameLabel];

    [self installConstraints];
}

- (void)setupBlurredView
{
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    darkView.backgroundColor = [UIColor blackColor];
    darkView.alpha = 0.5;

    [self.view addSubview:darkView];

    [darkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.view.bounds;

    [self.view addSubview:visualEffectView];
    [visualEffectView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)createNameLabel
{
    if (self.call.chat.friends.count == 1) {
        OCTFriend *friend = self.call.chat.friends.firstObject;

        self.nameLabel = [UILabel new];
        self.nameLabel.text = friend.nickname;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.nameLabel sizeToFit];

        [self.view addSubview:self.nameLabel];
    }
}

- (void)installConstraints
{
    [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(kIndent);
        make.left.equalTo(self.view.mas_left).with.offset(kIndent);
        make.right.equalTo(self.view.mas_right).with.offset(-kIndent);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.equalTo(30);
    }];
}

#pragma mark -  RBQFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(RBQFetchedResultsController *)controller
{
    self.call = [[self.callController fetchedObjects] firstObject];

    if (! self.call) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }

    [self didUpdateCall];
}

#pragma mark - Public
- (void)didUpdateCall
{}
@end
