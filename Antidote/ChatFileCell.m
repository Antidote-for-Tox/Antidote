//
//  ChatFileCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 14.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "ChatFileCell.h"
#import "UIView+Utilities.h"
#import "UIColor+Utilities.h"

static const CGFloat kCellHeight = 50.0;
static const NSTimeInterval kAnimationDuration = 0.5;

typedef NS_ENUM(NSUInteger, TypeImageViewType) {
    TypeImageViewTypeNone,
    TypeImageViewTypeBasic,
    TypeImageViewTypeDeleted,
    TypeImageViewTypeCanceled,
};

typedef NS_ENUM(NSUInteger, PlayPauseImageType) {
    PlayPauseImageTypeNone,
    PlayPauseImageTypePlay,
    PlayPauseImageTypePause,
};

@interface ChatFileCell()

@property (strong, nonatomic) UIImageView *typeImageView;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;

@property (strong, nonatomic) UIButton *yesButton;
@property (strong, nonatomic) UIButton *noButton;

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIButton *playPauseButton;

@property (assign, nonatomic) TypeImageViewType currentTypeImageViewType;
@property (assign, nonatomic) PlayPauseImageType currentPlayPauseImageType;
@property (strong, nonatomic) NSString *currentUTI;

@end

@implementation ChatFileCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];

    if (self) {
        [self createTypeImageView];
        [self createLabels];
        [self createYesNoButtons];
        [self createProgressViews];
    }

    return self;
}

#pragma mark -  Actions

- (void)yesButtonPressed
{
    [self.delegate chatFileCell:self answerButtonPressedWith:YES];
}

- (void)noButtonPressed
{
    [self.delegate chatFileCell:self answerButtonPressedWith:NO];
}

- (void)playPauseButtonPressed
{
    [self.delegate chatFileCellPausePlayButtonPressed:self];
}

#pragma mark -  Public

- (void)redraw
{
    [super redraw];

    [self redrawAnimated:NO];
}

- (void)redrawAnimated
{
    [super redraw];

    [self redrawAnimated:YES];
}

- (void)redrawLoadingPercentOnlyAnimated:(BOOL)animated
{
    [self updateDescriptionLabel];
    [self updateProgressViewAnimated:animated];
}

+ (CGFloat)heightWithFullDateString:(NSString *)fullDateString
{
    return [super heightWithFullDateString:fullDateString] + kCellHeight;
}

#pragma mark -  Private

- (void)createTypeImageView
{
    self.typeImageView = [[UIImageView alloc] init];
    self.typeImageView.tintColor = [UIColor uColorOpaqueWithWhite:150];
    [self.contentView addSubview:self.typeImageView];
}

- (void)createLabels
{
    self.titleLabel = [self.contentView addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
    self.titleLabel.font = [AppearanceManager fontHelveticaNeueWithSize:14];

    self.descriptionLabel = [self.contentView addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
    self.descriptionLabel.textColor = [UIColor uColorOpaqueWithWhite:160];
    self.descriptionLabel.font = [AppearanceManager fontHelveticaNeueLightWithSize:12];
}

- (void)createYesNoButtons
{
    UIImage *yesImage = [UIImage imageNamed:@"chat-file-download"];
    yesImage = [yesImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    UIImage *noImage = [UIImage imageNamed:@"chat-file-cancel"];
    noImage = [noImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    CGRect frame = CGRectZero;
    frame.size = yesImage.size;

    self.yesButton = [[UIButton alloc] initWithFrame:frame];
    [self.yesButton setImage:yesImage forState:UIControlStateNormal];
    [self.yesButton addTarget:self action:@selector(yesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.yesButton.tintColor = [AppearanceManager statusOnlineColor];
    [self.contentView addSubview:self.yesButton];

    frame.size = noImage.size;

    self.noButton = [[UIButton alloc] initWithFrame:frame];
    [self.noButton setImage:noImage forState:UIControlStateNormal];
    [self.noButton addTarget:self action:@selector(noButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.noButton.tintColor = [AppearanceManager statusBusyColor];
    [self.contentView addSubview:self.noButton];
}

- (void)createProgressViews
{
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progressTintColor = [AppearanceManager textMainColor];
    self.progressView.trackTintColor = [UIColor uColorOpaqueWithWhite:160];
    [self.contentView addSubview:self.progressView];

    self.playPauseButton = [UIButton new];
    self.playPauseButton.tintColor = [AppearanceManager textMainColor];
    [self.playPauseButton addTarget:self
                             action:@selector(playPauseButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.playPauseButton];

    self.currentPlayPauseImageType = PlayPauseImageTypeNone;
}

- (void)redrawAnimated:(BOOL)animated
{
    CGRect oldTitleLabelFrame = self.titleLabel.frame;
    CGRect oldDescriptionLabelFrame = self.descriptionLabel.frame;
    CGRect oldNoButtonFrame = self.noButton.frame;

    if (self.isOutgoing) {
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.descriptionLabel.textAlignment = NSTextAlignmentRight;
    }
    else {
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    }

    // order matters
    [self updateTypeImageViewAnimated:animated];
    [self updateYesButton];
    [self updateNoButton];
    [self updateTitleLabel];
    [self updateDescriptionLabel];
    [self updatePlayPauseButton];
    [self updateProgressViewAnimated:animated];

    CGRect newTitleLabelFrame = self.titleLabel.frame;
    CGRect newNoButtonFrame = self.noButton.frame;
    CGRect newDescriptionLabelFrame = self.descriptionLabel.frame;

    BOOL animateTitleLabel = ! CGRectEqualToRect(oldTitleLabelFrame, newTitleLabelFrame);
    BOOL animateNoButton   = ! CGRectEqualToRect(oldNoButtonFrame,   newNoButtonFrame);

    BOOL animateDescriptionLabel = self.descriptionLabel.alpha &&
        ! CGPointEqualToPoint(oldDescriptionLabelFrame.origin, newDescriptionLabelFrame.origin);

    if (animated && (animateTitleLabel || animateDescriptionLabel || animateNoButton)) {
        if (animateTitleLabel) {
            self.titleLabel.frame = oldTitleLabelFrame;
        }
        if (animateDescriptionLabel) {
            self.descriptionLabel.alpha = 0.0;
        }
        if (animateNoButton) {
            self.noButton.frame = oldNoButtonFrame;
        }

        self.userInteractionEnabled = NO;

        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self changeHiddenForSubview];

            if (animateTitleLabel) {
                self.titleLabel.frame = newTitleLabelFrame;
            }
            if (animateDescriptionLabel) {
                self.descriptionLabel.alpha = 1.0;
            }
            if (animateNoButton) {
                self.noButton.frame = newNoButtonFrame;
            }

        } completion:^(BOOL f) {
            self.userInteractionEnabled = YES;
        }];
    }
    else {
        [self changeHiddenForSubview];
    }
}

- (void)updatePlayPauseImageWith:(PlayPauseImageType)imageType
{
    if (self.currentPlayPauseImageType == imageType) {
        return;
    }
    self.currentPlayPauseImageType = imageType;

    UIImage *image = nil;

    if (imageType == PlayPauseImageTypePlay) {
        image = [UIImage imageNamed:@"chat-file-play"];
    }
    else if (imageType == PlayPauseImageTypePause) {
        image = [UIImage imageNamed:@"chat-file-pause"];
    }

    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [self.playPauseButton setImage:image forState:UIControlStateNormal];
}

- (void)changeHiddenForSubview
{
    if (self.type == ChatFileCellTypeWaitingConfirmation) {
        self.descriptionLabel.alpha = 1.0;

        self.yesButton.alpha = self.isOutgoing ? 0.0 : 1.0;
        self.noButton.alpha = 1.0;

        self.progressView.alpha = 0.0;
        self.playPauseButton.alpha = 0.0;
    }
    else if (self.type == ChatFileCellTypeDownloading) {
        self.descriptionLabel.alpha = 1.0;

        self.yesButton.alpha = 0.0;
        self.noButton.alpha = 1.0;

        self.progressView.alpha = 1.0;
        self.playPauseButton.alpha = self.isOutgoing ? 0.0 : 1.0;
    }
    else if (self.type == ChatFileCellTypeLoaded) {
        self.descriptionLabel.alpha = 0.0;

        self.yesButton.alpha = 0.0;
        self.noButton.alpha = 0.0;

        self.progressView.alpha = 0.0;
        self.playPauseButton.alpha = 0.0;
    }
    else if (self.type == ChatFileCellTypeDeleted ||
             self.type == ChatFileCellTypeCanceled)
    {
        self.descriptionLabel.alpha = 1.0;

        self.yesButton.alpha = 0.0;
        self.noButton.alpha = 0.0;

        self.progressView.alpha = 0.0;
        self.playPauseButton.alpha = 0.0;
    }
}

- (void)updateTypeImageViewAnimated:(BOOL)animated
{
    TypeImageViewType newType = TypeImageViewTypeBasic;

    if (self.type == ChatFileCellTypeDeleted) {
        newType = TypeImageViewTypeDeleted;
    }
    else if (self.type == ChatFileCellTypeCanceled) {
        newType = TypeImageViewTypeCanceled;
    }

    BOOL changeImage = NO;

    if (newType == TypeImageViewTypeDeleted || newType == TypeImageViewTypeCanceled) {
        changeImage = (self.currentTypeImageViewType != newType);
    }
    else if (newType == TypeImageViewTypeBasic) {
        if (self.currentUTI) {
            changeImage = ! [self.currentUTI isEqualToString:self.fileUTI];
        }
        else {
            changeImage = YES;
        }
    }

    if (changeImage) {
        self.currentTypeImageViewType = newType;
        self.currentUTI = (newType == TypeImageViewTypeBasic) ? self.fileUTI : nil;

        UIImage *image = nil;

        if (newType == TypeImageViewTypeBasic) {
            image = [self typeImageForCurrentUTI];
        }
        else if (newType == TypeImageViewTypeDeleted) {
            image = [UIImage imageNamed:@"chat-file-type-deleted"];
        }
        else if (newType == TypeImageViewTypeCanceled) {
            image = [UIImage imageNamed:@"chat-file-type-canceled"];
        }

        self.typeImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        if (animated) {
            CATransition *transition = [CATransition animation];
            transition.duration = kAnimationDuration;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionMoveIn;

            [self.typeImageView.layer addAnimation:transition forKey:nil];
        }
    }

    CGRect frame = CGRectZero;
    frame.size = self.typeImageView.image.size;
    frame.origin.x = 20.0;
    if (self.isOutgoing) {
        frame.origin.x = self.contentView.frame.size.width - frame.size.width - frame.origin.x;
    }
    frame.origin.y = [self startingOriginY] + (kCellHeight - frame.size.height) / 2;
    self.typeImageView.frame = frame;
}

- (void)updateYesButton
{
    if (self.type != ChatFileCellTypeWaitingConfirmation || self.isOutgoing) {
        return;
    }

    CGRect frame = self.yesButton.frame;
    frame.origin.x = self.frame.size.width - frame.size.width - 20.0;
    frame.origin.y = [self startingOriginY] + (kCellHeight - frame.size.height) / 2;
    self.yesButton.frame = frame;
}

- (void)updateNoButton
{
    if (self.type != ChatFileCellTypeWaitingConfirmation &&
        self.type != ChatFileCellTypeDownloading)
    {
        return;
    }

    CGRect frame = self.noButton.frame;
    frame.origin.x = 20.0;
    frame.origin.y = [self startingOriginY] + (kCellHeight - frame.size.height) / 2;

    if (! self.isOutgoing) {
        if (self.type == ChatFileCellTypeWaitingConfirmation) {
            frame.origin.x = CGRectGetMinX(self.yesButton.frame) - frame.size.width - frame.origin.x;
        }
        else if (self.type == ChatFileCellTypeDownloading) {
            frame.origin.x = self.frame.size.width - frame.size.width - 20.0;
        }
    }

    self.noButton.frame = frame;
}

- (void)updateTitleLabel
{
    self.titleLabel.text = self.fileName;

    if (self.type == ChatFileCellTypeWaitingConfirmation ||
        self.type == ChatFileCellTypeDownloading ||
        self.type == ChatFileCellTypeDeleted ||
        self.type == ChatFileCellTypeCanceled)
    {
        self.titleLabel.textColor = [UIColor blackColor];
    }
    else if (self.type == ChatFileCellTypeLoaded) {
        self.titleLabel.textColor = [AppearanceManager textMainColor];
    }

    [self.titleLabel sizeToFit];
    CGRect frame = self.titleLabel.frame;
    frame.origin.y = self.typeImageView.frame.origin.y;

    if (self.isOutgoing) {
        frame.origin.x = 20.0;

        if (self.type == ChatFileCellTypeWaitingConfirmation ||
            self.type == ChatFileCellTypeDownloading)
        {
            frame.origin.x = CGRectGetMaxX(self.noButton.frame) + 5.0;
        }
        else if (self.type == ChatFileCellTypeDeleted ||
                self.type == ChatFileCellTypeCanceled)
        {
            // nothing
        }
        else if (self.type == ChatFileCellTypeLoaded) {
            frame.origin.y = [self startingOriginY] + (kCellHeight - frame.size.height) / 2;
        }

        frame.size.width = CGRectGetMinX(self.typeImageView.frame) - frame.origin.x - 5.0;
    }
    else {
        frame.origin.x = CGRectGetMaxX(self.typeImageView.frame) + 5.0;
        frame.size.width = self.contentView.frame.size.width - frame.origin.x - 5.0;

        if (self.type == ChatFileCellTypeWaitingConfirmation ||
            self.type == ChatFileCellTypeDownloading)
        {
            frame.size.width = CGRectGetMinX(self.noButton.frame) - frame.origin.x - 5.0;
        }
        else if (self.type == ChatFileCellTypeDeleted ||
                self.type == ChatFileCellTypeCanceled)
        {
            // nothing
        }
        else if (self.type == ChatFileCellTypeLoaded) {
            frame.origin.y = [self startingOriginY] + (kCellHeight - frame.size.height) / 2;
        }
    }

    self.titleLabel.frame = frame;
}

- (void)updateDescriptionLabel
{
    if (self.type != ChatFileCellTypeWaitingConfirmation &&
        self.type != ChatFileCellTypeDownloading &&
        self.type != ChatFileCellTypeDeleted &&
        self.type != ChatFileCellTypeCanceled)
    {
        return;
    }

    if (self.type == ChatFileCellTypeWaitingConfirmation) {
        self.descriptionLabel.text = self.fileSize;

    }
    else if (self.type == ChatFileCellTypeDownloading) {
        self.descriptionLabel.text = [NSString stringWithFormat:@"%d%%", (int) (self.loadedPercent * 100)];
    }
    else if (self.type == ChatFileCellTypeDeleted) {
        self.descriptionLabel.text = NSLocalizedString(@"Deleted", @"Chat");
    }
    else if (self.type == ChatFileCellTypeCanceled) {
        self.descriptionLabel.text = NSLocalizedString(@"Canceled", @"Chat");
    }

    [self.descriptionLabel sizeToFit];
    CGRect frame = self.descriptionLabel.frame;
    frame.origin.y = CGRectGetMaxY(self.typeImageView.frame) - frame.size.height;

    if (self.isOutgoing && self.type == ChatFileCellTypeDownloading) {
        // nothing
    }
    else {
        frame.size.width = self.titleLabel.frame.size.width;
    }

    if (self.type == ChatFileCellTypeWaitingConfirmation ||
        self.type == ChatFileCellTypeDeleted ||
        self.type == ChatFileCellTypeCanceled)
    {
        frame.origin.x = self.titleLabel.frame.origin.x;
    }
    else if (self.type == ChatFileCellTypeDownloading) {
        if (self.isOutgoing) {
            frame.origin.x = CGRectGetMaxX(self.noButton.frame) + 5.0;
        }
        else {
            frame.origin.x = CGRectGetMinX(self.noButton.frame) - self.descriptionLabel.frame.size.width - 5.0;
        }
    }

    self.descriptionLabel.frame = frame;
}

- (void)updatePlayPauseButton
{
    if (self.type != ChatFileCellTypeDownloading) {
        return;
    }

    [self updatePlayPauseImageWith:self.isPaused ? PlayPauseImageTypePlay : PlayPauseImageTypePause];

    CGRect frame = CGRectZero;
    frame.size = self.playPauseButton.imageView.image.size;
    frame.origin.x = self.titleLabel.frame.origin.x - 4.0;
    frame.origin.y = CGRectGetMaxY(self.typeImageView.frame) - frame.size.height + 5.0;
    self.playPauseButton.frame = frame;
}

- (void)updateProgressViewAnimated:(BOOL)animated
{
    if (self.type != ChatFileCellTypeDownloading) {
        return;
    }

    [self.progressView setProgress:self.loadedPercent animated:animated];

    CGRect frame = self.progressView.frame;
    frame.size.height = 10.0;
    frame.origin.y = CGRectGetMinY(self.playPauseButton.frame) +
        self.playPauseButton.frame.size.width - frame.size.height - 3.0;

    if (self.isOutgoing) {
        frame.origin.x = CGRectGetMaxX(self.descriptionLabel.frame) + 5.0;
        frame.size.width = CGRectGetMinX(self.typeImageView.frame) - frame.origin.x - 5.0;
    }
    else {
        frame.origin.x = CGRectGetMaxX(self.playPauseButton.frame) + 5.0;
        frame.size.width = CGRectGetMinX(self.descriptionLabel.frame) - frame.origin.x - 10.0;
    }

    self.progressView.frame = frame;
}

- (UIImage *)typeImageForCurrentUTI
{
    NSString *basicName = @"chat-file-type-basic";

    if (! self.fileUTI) {
        return [UIImage imageNamed:basicName];
    }

    CFStringRef fileUTI = (__bridge CFStringRef)(self.fileUTI);

    #define MATCH(theFileUTI, theImageName) \
        if (UTTypeEqual(fileUTI, theFileUTI)) { \
            return [UIImage imageNamed:theImageName]; \
        }

    MATCH(kUTTypeGIF,        @"chat-file-type-gif")
    MATCH(kUTTypeHTML,       @"chat-file-type-html")
    MATCH(kUTTypeJPEG,       @"chat-file-type-jpg")
    MATCH(kUTTypeMP3,        @"chat-file-type-mp3")
    MATCH(kUTTypeMPEG,       @"chat-file-type-mpg")
    MATCH(kUTTypePDF,        @"chat-file-type-pdf")
    MATCH(kUTTypePNG,        @"chat-file-type-png")
    MATCH(kUTTypeTIFF,       @"chat-file-type-tif")
    MATCH(kUTTypePlainText,  @"chat-file-type-txt")

    #undef MATCH

    NSString *extension = (__bridge_transfer NSString *)
        (UTTypeCopyPreferredTagWithClass(fileUTI, kUTTagClassFilenameExtension));

    if (! extension) {
        return [UIImage imageNamed:basicName];
    }

    #define MATCH(theExtension, theImageName) \
        if ([extension isEqual:theExtension]) { \
            return [UIImage imageNamed:theImageName]; \
        }

    MATCH(@"7z",    @"chat-file-type-7zip")
    MATCH(@"aac",   @"chat-file-type-aac")
    MATCH(@"avi",   @"chat-file-type-avi")
    MATCH(@"css",   @"chat-file-type-css")
    MATCH(@"csv",   @"chat-file-type-csv")
    MATCH(@"doc",   @"chat-file-type-doc")
    MATCH(@"ebup",  @"chat-file-type-ebup")
    MATCH(@"exe",   @"chat-file-type-exe")
    MATCH(@"fb2",   @"chat-file-type-fb2")
    MATCH(@"flv",   @"chat-file-type-flv")
    MATCH(@"mov",   @"chat-file-type-mov")
    MATCH(@"ogg",   @"chat-file-type-ogg")
    MATCH(@"otf",   @"chat-file-type-otf")
    MATCH(@"ppt",   @"chat-file-type-ppt")
    MATCH(@"psd",   @"chat-file-type-psd")
    MATCH(@"rar",   @"chat-file-type-rar")
    MATCH(@"tar",   @"chat-file-type-tar")
    MATCH(@"ttf",   @"chat-file-type-ttf")
    MATCH(@"wav",   @"chat-file-type-wav")
    MATCH(@"wma",   @"chat-file-type-wma")
    MATCH(@"xls",   @"chat-file-type-xls")
    MATCH(@"zip",   @"chat-file-type-zip")

    #undef MATCH

    return [UIImage imageNamed:basicName];
}

@end
