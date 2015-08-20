//
//  VideoCallViewController.h
//  Antidote
//
//  Created by Chuong Vu on 8/17/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ActiveCallViewController.h"

@interface VideoCallViewController : ActiveCallViewController

/**
 * YES if the video view is being shown, otherwise NO.
 */
@property (nonatomic, assign, readonly) BOOL videoViewIsShown;

/**
 * Since it takes a while for the preview layer to be loaded,
 * it is best to set this to YES to indicate that one is loaded and in progress
 * or that it is already present.
 * Set to YES before providing a preview layer.
 */
@property (nonatomic, assign) BOOL previewViewLoaded;

/**
 * Provide video view to view controller
 * @param view Video view to provide.
 */
- (void)provideVideoView:(UIView *)view;

/**
 * Provide preview view layer to view controller.
 * @param layer Layer of the preview video.
 */
- (void)providePreviewLayer:(CALayer *)layer;

@end
