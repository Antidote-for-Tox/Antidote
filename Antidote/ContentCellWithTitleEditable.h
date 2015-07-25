//
//  ContentCellWithTitleEditable.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ContentCellWithTitleBasic.h"

@class ContentCellWithTitleEditable;
@protocol ContentCellWithTitleEditableDelegate <ContentCellWithTitleBasicDelegate>

@optional
- (void)contentCellWithTitleEditableDidBeginEditing:(ContentCellWithTitleEditable *)cell;
- (void)contentCellWithTitleEditableDidEndEditing:(ContentCellWithTitleEditable *)cell;
- (void)contentCellWithTitleEditableWantsToResize:(ContentCellWithTitleEditable *)cell;

@end

@interface ContentCellWithTitleEditable : ContentCellWithTitleBasic

@property (weak, nonatomic) id<ContentCellWithTitleEditableDelegate> delegate;

@property (assign, nonatomic) NSUInteger maxMainTextLength;

- (void)startEditing;

@end
