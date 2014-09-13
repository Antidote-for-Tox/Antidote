//
//  CellWithNameStatusAvatar.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 12.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsNameStatusAvatarCellDelegate;

@interface CellWithNameStatusAvatar : UITableViewCell

@property (weak, nonatomic) id <SettingsNameStatusAvatarCellDelegate> delegate;

@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *statusMessage;

@property (assign, nonatomic) NSUInteger maxNameLength;
@property (assign, nonatomic) NSUInteger maxStatusMessageLength;

- (void)redraw;

+ (CGFloat)height;
+ (CGFloat)avatarHeight;

@end

@protocol SettingsNameStatusAvatarCellDelegate <NSObject>
- (void)cellWithNameStatusAvatar:(CellWithNameStatusAvatar *)cell nameChangedTo:(NSString *)newName;
- (void)cellWithNameStatusAvatar:(CellWithNameStatusAvatar *)cell
          statusMessageChangedTo:(NSString *)newStatusMessage;
@end
