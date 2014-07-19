//
//  SettingsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "SettingsViewController.h"
#import "CopyLabel.h"
#import "NSString+Utilities.h"
#import "ToxManager.h"

@interface SettingsViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UILabel *toxIdTitleLabel;
@property (strong, nonatomic) CopyLabel *toxIdValueLabel;

@end

@implementation SettingsViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
    }

    return self;
}

- (void)loadView
{
    CGRect frame = CGRectZero;
    frame.size = [[UIScreen mainScreen] applicationFrame].size;

    self.view = [[UIView alloc] initWithFrame:frame];

    [self createScrollView];
    [self createToxIdLabels];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  Private

- (void)createScrollView
{
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
}

- (void)createToxIdLabels
{
    self.toxIdTitleLabel = [self addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
    self.toxIdTitleLabel.text = NSLocalizedString(@"Tox ID", @"Settings");

    self.toxIdValueLabel = [CopyLabel new];
    self.toxIdValueLabel.textColor = [UIColor grayColor];
    self.toxIdValueLabel.backgroundColor = [UIColor clearColor];
    self.toxIdValueLabel.numberOfLines = 0;
    self.toxIdValueLabel.text = [[ToxManager sharedInstance] toxId];
    [self.scrollView addSubview:self.toxIdValueLabel];
}

- (void)adjustSubviews
{
    self.scrollView.frame = self.view.bounds;

    CGFloat currentOriginY = 0.0;
    const CGFloat yIndentation = 10.0;

    CGRect frame = CGRectZero;

    {
        frame.size = [self.toxIdTitleLabel.text stringSizeWithFont:self.toxIdTitleLabel.font];
        frame.origin.x = 10.0;
        frame.origin.y = currentOriginY + yIndentation;
        self.toxIdTitleLabel.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        CGFloat xIndentation = self.toxIdTitleLabel.frame.origin.x;
        CGFloat maxWidth = self.scrollView.bounds.size.width - 2 * xIndentation;

        frame = CGRectZero;
        frame.size = [self.toxIdValueLabel.text stringSizeWithFont:self.toxIdValueLabel.font
                                                 constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
        frame.origin.x = xIndentation;
        frame.origin.y = currentOriginY + yIndentation;
        self.toxIdValueLabel.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.origin.x, currentOriginY + yIndentation);
}

- (UILabel *)addLabelWithTextColor:(UIColor *)textColor bgColor:(UIColor *)bgColor
{
    UILabel *label = [UILabel new];
    label.textColor = textColor;
    label.backgroundColor = bgColor;
    [self.scrollView addSubview:label];

    return label;
}

@end
