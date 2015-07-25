//
//  ContentCellWithTitleBasic.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ContentCell.h"

@class ContentCellWithTitleBasic;
@protocol ContentCellWithTitleBasicDelegate <NSObject>

@optional
- (void)contentCellWithTitleBasicDidPressButton:(ContentCellWithTitleBasic *)cell;

@end

@interface ContentCellWithTitleBasic : ContentCell

@property (weak, nonatomic) id<ContentCellWithTitleBasicDelegate> delegate;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *buttonTitle;
@property (strong, nonatomic) NSString *mainText;

@property (strong, nonatomic, readonly) UILabel *titleLabel;

@end
