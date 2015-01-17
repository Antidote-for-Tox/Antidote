//
//  ChatBackgroundsCollectionvViewCell.m
//  Antidote
//
//  Created by Nikolay Palamar on 12/01/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ChatBackgroundsCollectionvViewCell.h"
#import "AppearanceManager.h"
#import "UIImage+Utilities.h"

static const CGFloat kImageViewRadius = 12.0f;
static const CGFloat kImageViewOffset = 4.0f;

@interface ChatBackgroundsCollectionvViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *checkMarkImageView;

@end

@implementation ChatBackgroundsCollectionvViewCell

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self commonLayoutSubviews];
}

#pragma mark - Public

+ (NSString *)reusableIdentifier
{
    return NSStringFromClass([ChatBackgroundsCollectionvViewCell class]);
}

#pragma mark - Properties

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setCheked:(BOOL)cheked
{
    _cheked = cheked;
    self.checkMarkImageView.hidden = !cheked;
}

#pragma mark - Private Logic

- (void)commonInit
{
    self.imageView = [UIImageView new];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    self.imageView.layer.borderWidth = 0.5f;
    self.imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.imageView.layer.cornerRadius = 2.0f;
  
    UIImage *image = [UIImage imageNamed:@"check-image"];
    self.checkMarkImageView = [UIImageView new];
    self.checkMarkImageView.layer.cornerRadius = kImageViewRadius;
    self.checkMarkImageView.hidden = !self.cheked;
    self.checkMarkImageView.image = image;
    [self.checkMarkImageView setBackgroundColor:[AppearanceManager textMainColor]];
    [self.contentView addSubview:self.checkMarkImageView];
}

#pragma mark - Private UI

- (void)commonLayoutSubviews
{
    self.imageView.frame = self.bounds;
    
    CGRect frame = self.checkMarkImageView.frame;
    frame.size.width = frame.size.height = kImageViewRadius * 2;
    frame.origin.x = self.bounds.size.width - frame.size.width - kImageViewOffset;
    frame.origin.y = self.bounds.size.height - frame.size.height - kImageViewOffset;
    self.checkMarkImageView.frame = frame;
}

@end