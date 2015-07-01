//
//  CallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/1/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "CallViewController.h"
#import "Helper.h"

NSString *const kCallViewControllerUserIdentifier = @"callViewController";

@interface CallViewController () <RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic, readwrite) OCTChat *chat;
@property (strong, nonatomic) RBQFetchedResultsController *callController;

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

    if (! _callController) {
        return nil;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.opaque = NO;

    [self setupBlurredView];
}

#pragma mark -  RBQFetchedResultsControllerDelegate



#pragma mark - Private

- (void)setupBlurredView
{
    UIView *blurredView = [[UIView alloc] initWithFrame:self.view.bounds];
    blurredView.backgroundColor = [UIColor blackColor];
    blurredView.alpha = 0.5;
    [self.view addSubview:blurredView];
}
@end
