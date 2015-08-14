//
//  VideoAndPreviewView.m
//  Antidote
//
//  Created by Chuong Vu on 8/11/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "VideoAndPreviewView.h"
#import "Masonry.h"

static const CGFloat kPreviewViewWidth = 75.0;
static const CGFloat kPreviewViewHeight = 100.0;
@interface VideoAndPreviewView ()

@property (strong, nonatomic) UIView *previewView;
@property (strong, nonatomic) UIButton *videoViewButton;

@end

@implementation VideoAndPreviewView

#pragma mark Life cycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.backgroundColor = [UIColor blackColor];

    [self createVideoViewButton];

    [self createPreviewView];

    [self installConstraints];

    return self;
}

#pragma mark - View setup

- (void)createVideoViewButton
{
    self.videoViewButton = [UIButton new];
    [self.videoViewButton addTarget:self
                             action:@selector(videoViewTapped)
                   forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.videoViewButton];
}

- (void)createPreviewView
{
    self.previewView = [UIView new];
    self.previewView.backgroundColor = [UIColor blackColor];
    self.previewView.userInteractionEnabled = NO;
    self.previewView.hidden = YES;

    [self addSubview:self.previewView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustPreviewLayer];

}
- (void)installConstraints
{
    [self.videoViewButton makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.previewView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(kPreviewViewHeight);
        make.width.equalTo(kPreviewViewWidth);
    }];
}

#pragma mark - Public

- (void)setVideoView:(UIView *)videoView
{
    if (videoView == _videoView) {
        return;
    }

    if (_videoView) {
        [_videoView removeFromSuperview];
    }

    _videoView = videoView;

    if (! _videoView) {
        return;
    }

    _videoView.userInteractionEnabled = NO;
    [self insertSubview:_videoView belowSubview:self.previewView];

    [self.videoView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.previewView);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self);
    }];
}

- (void)setPreviewLayer:(CALayer *)previewLayer
{
    if (previewLayer == _previewLayer) {
        return;
    }

    if (_previewLayer) {
        [_previewLayer removeFromSuperlayer];
    }

    _previewLayer = previewLayer;

    if (! _previewLayer) {
        self.previewView.hidden = YES;
        return;
    }

    [self.previewView.layer addSublayer:self.previewLayer];
    self.previewView.hidden = NO;
    [self adjustPreviewLayer];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];

    if (hidden) {
        /** release any resources from video engine **/
        [self.previewLayer removeFromSuperlayer];
        [self.videoView removeFromSuperview];
        self.videoView = nil;
    }
}
#pragma mark - Private

- (void)adjustPreviewLayer
{
    self.previewLayer.frame = self.previewView.bounds;
}

#pragma mark - VideoAndPreviewViewDelegate

- (void)videoViewTapped
{
    if ([self.delegate respondsToSelector:@selector(videoAndPreviewViewTapped:)]) {
        [self.delegate videoAndPreviewViewTapped:self];
    }
}

@end
