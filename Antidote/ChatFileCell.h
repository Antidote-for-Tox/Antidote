//
//  ChatFileCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 14.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ChatFileCellType) {
    ChatFileCellTypeIncomingWaitingConfirmation,
    ChatFileCellTypeIncomingDownloading,
    ChatFileCellTypeIncomingLoaded,
    ChatFileCellTypeIncomingDeleted,
    ChatFileCellTypeIncomingCanceled,
};

@protocol ChatFileCellDelegate;
@interface ChatFileCell : UITableViewCell

@property (weak, nonatomic) id <ChatFileCellDelegate> delegate;

@property (assign, nonatomic) ChatFileCellType type;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *fileSize;

// from 0.0 to 1.0
@property (assign, nonatomic) CGFloat loadedPercent;
@property (assign, nonatomic) BOOL isPaused;

- (void)redrawAnimated:(BOOL)animated;
- (void)redrawLoadingPercentOnlyAnimated:(BOOL)animated;

+ (CGFloat)height;
+ (NSString *)reuseIdentifier;

@end

@protocol ChatFileCellDelegate <NSObject>
- (void)chatFileCell:(ChatFileCell *)cell answerButtonPressedWith:(BOOL)answer;
@end
