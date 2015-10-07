//
//  AboutViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 26/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "AboutViewController.h"
#import "UITableViewCell+Utilities.h"
#import "OCTTox.h"

typedef NS_ENUM(NSUInteger, CellType) {
    CellTypeAntidoteVersion,
    CellTypeAntidoteBuild,
    CellTypeToxcoreVersion,
};

@interface AboutViewController ()

@end

@implementation AboutViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super initWithTitle:NSLocalizedString(@"About", @"About") tableStyle:UITableViewStyleGrouped tableStructure:@[
                @[
                    @(CellTypeAntidoteVersion),
                    @(CellTypeAntidoteBuild),
                ],
                @[
                    @(CellTypeToxcoreVersion),
                ],
            ]];

    if (! self) {
        return nil;
    }

    return self;
}

#pragma mark -  Override

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    switch (type) {
        case CellTypeAntidoteVersion:
        case CellTypeAntidoteBuild:
        case CellTypeToxcoreVersion:
            return [self cellWithValueAtIndexPath:indexPath withType:type];
    }
}

- (void)registerCellsForTableView
{}

#pragma mark -  Private

- (UITableViewCell *)cellWithValueAtIndexPath:(NSIndexPath *)indexPath withType:(CellType)type
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[UITableViewCell reuseIdentifier]];

    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier :[UITableViewCell reuseIdentifier]];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    switch (type) {
        case CellTypeAntidoteVersion:
            cell.textLabel.text = NSLocalizedString(@"Antidote version", @"About");
            cell.detailTextLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            break;
        case CellTypeAntidoteBuild:
            cell.textLabel.text = NSLocalizedString(@"Antidote build", @"About");
            cell.detailTextLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
            break;
        case CellTypeToxcoreVersion:
            cell.textLabel.text = NSLocalizedString(@"toxcore version", @"About");
            cell.detailTextLabel.text = [OCTTox version];
            break;
    }

    return cell;
}

@end
