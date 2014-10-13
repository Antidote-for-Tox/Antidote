//
//  ChatFileCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 14.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatBasicCell.h"

typedef NS_ENUM(NSUInteger, ChatFileCellType) {
    ChatFileCellTypeWaitingConfirmation,
    ChatFileCellTypeDownloading,
    ChatFileCellTypeLoaded,
    ChatFileCellTypeDeleted,
    ChatFileCellTypeCanceled,
};

@protocol ChatFileCellDelegate;

@interface ChatFileCell : ChatBasicCell

@property (weak, nonatomic) id <ChatFileCellDelegate> delegate;

@property (assign, nonatomic) ChatFileCellType type;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *fileSize;
@property (strong, nonatomic) NSString *fileUTI;

// from 0.0 to 1.0
@property (assign, nonatomic) CGFloat loadedPercent;
@property (assign, nonatomic) BOOL isPaused;

- (void)redrawAnimated;
- (void)redrawLoadingPercentOnlyAnimated:(BOOL)animated;

+ (CGFloat)heightWithFullDateString:(NSString *)fullDateString;

@end

@protocol ChatFileCellDelegate <NSObject>
- (void)chatFileCell:(ChatFileCell *)cell answerButtonPressedWith:(BOOL)answer;
- (void)chatFileCellPausePlayButtonPressed:(ChatFileCell *)cell;
@end
