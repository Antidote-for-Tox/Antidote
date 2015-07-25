//
//  ContentCellWithTitle.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 19/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ContentCell.h"

@class ContentCellWithTitle;
@protocol ContentCellWithTitleDelegate <NSObject>

- (void)contentCellWithTitleDidPressButton:(ContentCellWithTitle *)cell;

@optional;
- (void)contentCellWithTitleDidBeginEditing:(ContentCellWithTitle *)cell;
- (void)contentCellWithTitleWantsToResize:(ContentCellWithTitle *)cell;
- (void)contentCellWithTitle:(ContentCellWithTitle *)cell didChangeMainText:(NSString *)mainText;

@end

@interface ContentCellWithTitle : ContentCell

@property (weak, nonatomic) id<ContentCellWithTitleDelegate> delegate;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *buttonTitle;
@property (strong, nonatomic) NSString *mainText;

@property (assign, nonatomic) BOOL editable;
@property (assign, nonatomic) NSUInteger maxMainTextLength;

@end
