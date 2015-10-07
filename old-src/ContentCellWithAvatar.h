//
//  ContentCellWithAvatar.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 24/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ContentCell.h"

extern const CGFloat kContentCellWithAvatarImageSize;

@class ContentCellWithAvatar;
@protocol ContentCellWithAvatarDelegate <NSObject>
- (void)contentCellWithAvatarImagePressed:(ContentCellWithAvatar *)cell;
@end

@interface ContentCellWithAvatar : ContentCell

@property (weak, nonatomic) id<ContentCellWithAvatarDelegate> delegate;

@property (strong, nonatomic) UIImage *avatar;

@end
