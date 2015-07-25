//
//  ContentCellWithTitleImmutable.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ContentCellWithTitleBasic.h"

@class ContentCellWithTitleImmutable;
@protocol ContentCellWithTitleImmutableDelegate <ContentCellWithTitleBasicDelegate>

@optional
- (void)contentCellWithTitleImmutableEditButtonPressed:(ContentCellWithTitleImmutable *)cell;

@end

@interface ContentCellWithTitleImmutable : ContentCellWithTitleBasic

@property (weak, nonatomic) id<ContentCellWithTitleImmutableDelegate> delegate;

@property (assign, nonatomic) BOOL showEditButton;

@end
