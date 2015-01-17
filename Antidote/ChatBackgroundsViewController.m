//
//  ChatBackgroundsViewController.m
//  Antidote
//
//  Created by Nikolay Palamar on 12/01/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ChatBackgroundsViewController.h"
#import "ChatBackgroundsCollectionvViewCell.h"
#import "UserInfoManager.h"

static NSString *const kBackgroundImagePrefix = @"background-";
static const CGFloat kCellInsets = 4.5f;

@interface ChatBackgroundsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSIndexPath *lastSelectedImageIndexPath;
@property (assign, nonatomic) NSUInteger selectedBackgroundNumber;

@end

@implementation ChatBackgroundsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    [self commonDidLoad];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self commonDidLayoutSubviews];
    
    [self.flowLayout setItemSize:CGSizeMake([self cellWidthHeight], [self cellWidthHeight])];
}

#pragma mark - Action

- (void)selectButtonPressed
{
    self.selectedBackgroundNumber = self.lastSelectedImageIndexPath.item;
    [UserInfoManager sharedInstance].uChatSelectedBackgroundIndex = @(self.selectedBackgroundNumber);
    [self.collectionView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.lastSelectedImageIndexPath = indexPath;
    
    NSString *imageName = [NSString stringWithFormat:@"%@%ld", kBackgroundImagePrefix, (long)indexPath.item];
    UIImage *image = [UIImage imageNamed:imageName];
    
    UIViewController *imageViewController = [UIViewController new];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageViewController.view addSubview:imageView];
    imageView.frame = imageViewController.view.frame;
   
    NSString *rightButtonTitle = NSLocalizedString(@"Select", @"");
    imageViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                             initWithTitle:rightButtonTitle
                                                             style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(selectButtonPressed)];
    imageViewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:imageViewController animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reusableIdentifier = [ChatBackgroundsCollectionvViewCell reusableIdentifier];
    ChatBackgroundsCollectionvViewCell *cell = [collectionView
                                                dequeueReusableCellWithReuseIdentifier:reusableIdentifier
                                                forIndexPath:indexPath];
    NSString *imageName = [NSString stringWithFormat:@"%@%ld", kBackgroundImagePrefix, (long)indexPath.item];
    UIImage *image = [UIImage imageNamed:imageName];
   
    cell.image = image;
    cell.cheked = (unsigned long)indexPath.item == self.selectedBackgroundNumber;
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - Private Logic

- (void)commonDidLoad
{
    self.title = NSLocalizedString(@"Chat Background" , @"ChatBackgroundsViewController");
    
    self.view.backgroundColor = [UIColor whiteColor];
   
    self.flowLayout = [UICollectionViewFlowLayout new];
    [self.flowLayout setMinimumLineSpacing:kCellInsets];
    [self.flowLayout setMinimumInteritemSpacing:kCellInsets];
    [self.flowLayout setSectionInset:UIEdgeInsetsMake(kCellInsets, kCellInsets, kCellInsets, kCellInsets)];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    self.collectionView.showsHorizontalScrollIndicator = self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[ChatBackgroundsCollectionvViewCell class]
            forCellWithReuseIdentifier:[ChatBackgroundsCollectionvViewCell reusableIdentifier]];
    [self.view addSubview:self.collectionView];
}

#pragma mark - Private Data

- (void)loadData
{
    self.selectedBackgroundNumber = [UserInfoManager sharedInstance].uChatSelectedBackgroundIndex.integerValue;
}

#pragma mark - Private UI

- (void)commonDidLayoutSubviews
{
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - Private Utilities

- (CGFloat)cellWidthHeight
{
    NSUInteger numberOfCells = [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? 3 : 5;
    NSUInteger numberOfInstes = [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? 4 : 6;
    return floorf((self.view.bounds.size.width - kCellInsets * numberOfInstes) / numberOfCells);
}

@end