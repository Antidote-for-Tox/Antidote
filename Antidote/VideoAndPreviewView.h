//
//  VideoAndPreviewView.h
//  Antidote
//
//  Created by Chuong Vu on 8/11/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * View that holds both the video view and preview
 * This class is responsible for showing the video UI.
 * You can use this without having a video view. If it's not provided or
 * set to new, it will be a black view which is useful for sending video only mode.
 */

@interface VideoAndPreviewView : UIView

/**
 * Setting this to nil or leaving it nil will leave a
 * default black view.
 */
@property (strong, nonatomic) UIView *videoView;

/**
 * The preview layer for the preview video.
 * Setting this to nil will hide the preview view.
 */
@property (strong, nonatomic) CALayer *previewLayer;

@end
