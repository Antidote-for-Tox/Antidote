//
//  StatusViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 19/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <objcTox/OCTSubmanagerUser.h>

#import "StatusViewController.h"
#import "StatusCircleView.h"
#import "ContentCellSimple.h"
#import "ContentSeparatorCell.h"
#import "UITableViewCell+Utilities.h"
#import "Helper.h"
#import "RunningContext.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeSeparatorTransparent,
    CellTypeOnline,
    CellTypeAway,
    CellTypeBusy,
};

@interface StatusViewController ()

@end

@implementation StatusViewController

#pragma mark -  Lifecycle

- (id)init
{
    return [super initWithTitle:NSLocalizedString(@"Status", @"Status") tableStyle:UITableViewStylePlain tableStructure:@[
                @[
                    @(CellTypeSeparatorTransparent),
                    @(CellTypeOnline),
                    @(CellTypeAway),
                    @(CellTypeBusy),
                ],
            ]];
}

#pragma mark -  Override

- (void)configureTableView
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[ContentSeparatorCell class] forCellReuseIdentifier:[ContentSeparatorCell reuseIdentifier]];
    [self.tableView registerClass:[ContentCellSimple class] forCellReuseIdentifier:[ContentCellSimple reuseIdentifier]];
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    switch (type) {
        case CellTypeSeparatorTransparent:
            return [self separatorCellAtIndexPath:indexPath isGray:NO];
        case CellTypeOnline:
        case CellTypeAway:
        case CellTypeBusy:
            return [self statusCellAtIndexPath:indexPath type:type];
    }
    ;
}

#pragma mark -  UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    switch (type) {
        case CellTypeSeparatorTransparent:
            // nop
            break;
        case CellTypeOnline:
        case CellTypeAway:
        case CellTypeBusy:
            [self didSelectUserStatus:[self userStatusFromType:type]];
            break;
    }
    ;
}

#pragma mark -  Private

- (ContentSeparatorCell *)separatorCellAtIndexPath:(NSIndexPath *)indexPath isGray:(BOOL)isGray
{
    ContentSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[ContentSeparatorCell reuseIdentifier]
                                                                      forIndexPath:indexPath];
    cell.showGraySeparator = isGray;

    return cell;
}

- (ContentCellSimple *)statusCellAtIndexPath:(NSIndexPath *)indexPath type:(CellType)type
{
    OCTToxUserStatus status = [self userStatusFromType:type];
    StatusCircleStatus circleStatus = [Helper circleStatusFromUserStatus:status];

    NSString *identifier = [ContentCellSimple reuseIdentifier];
    ContentCellSimple *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.boldTitle = NO;
    cell.title = [Helper circleStatusToString:circleStatus];
    cell.accessoryType = ([RunningContext context].toxManager.user.userStatus == status) ?
                         UITableViewCellAccessoryCheckmark :
                         UITableViewCellAccessoryNone;

    StatusCircleView *circleView = [self statusCircleViewWithStatus:circleStatus];
    cell.leftAccessoryView = circleView;
    cell.leftAccessoryViewSize = CGSizeMake(circleView.side, circleView.side);

    return cell;
}

- (OCTToxUserStatus)userStatusFromType:(CellType)type
{
    switch (type) {
        case CellTypeSeparatorTransparent:
            NSAssert(NO, @"We shouldn't be there, something went terrible wrong.");
            return 0;
        case CellTypeOnline:
            return OCTToxUserStatusNone;
        case CellTypeAway:
            return OCTToxUserStatusAway;
        case CellTypeBusy:
            return OCTToxUserStatusBusy;
    }
    ;
}

- (StatusCircleView *)statusCircleViewWithStatus:(StatusCircleStatus)status
{
    StatusCircleView *statusView = [StatusCircleView new];
    statusView.showWhiteBorder = NO;
    statusView.status = status;
    [statusView redraw];

    return statusView;
}

- (void)didSelectUserStatus:(OCTToxUserStatus)status
{
    [RunningContext context].toxManager.user.userStatus = status;
    [self.tableView reloadData];
}

@end
