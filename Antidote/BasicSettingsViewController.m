//
//  BasicSettingsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 31.01.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "BasicSettingsViewController.h"
#import "UIViewController+Utilities.h"

#define OVERRIDE_METHOD @throw \
        [NSException exceptionWithName:NSInternalInconsistencyException \
                                reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] \
                              userInfo:nil];

@interface BasicSettingsViewController ()
@property (assign, nonatomic) UITableViewStyle tableStyle;
@end

@implementation BasicSettingsViewController

#pragma mark -  Lifecycle

- (instancetype)initWithTitle:(NSString *)title
                   tableStyle:(UITableViewStyle)tableStyle
               tableStructure:(NSArray *)tableStructure
{
    self = [super init];

    if (self) {
        self.title = title;
        _tableStyle = tableStyle;
        _tableStructure = tableStructure;
    }

    return self;
}

- (void)loadView
{
    [self loadWhiteView];

    [self createTableView];
    [self basicSettings_installConstraints];
}

#pragma mark -  Public

- (NSIndexPath *)indexPathForCellType:(NSInteger)type
{
    for (NSUInteger section = 0; section < self.tableStructure.count; section++) {
        NSArray *subArray = self.tableStructure[section];

        for (NSUInteger row = 0; row < subArray.count; row++) {
            NSNumber *number = subArray[row];

            if (number.integerValue == type) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }

    return nil;
}

- (NSInteger)cellTypeForIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *number = self.tableStructure[indexPath.section][indexPath.row];
    return number.unsignedIntegerValue;
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OVERRIDE_METHOD
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableStructure.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *subArray = self.tableStructure[section];
    return subArray.count;
}

#pragma mark -  Private

- (void)createTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.tableStyle];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self configureTableView];
    [self registerCellsForTableView];

    [self.view addSubview:self.tableView];
}

- (void)basicSettings_installConstraints
{
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)configureTableView
{}

- (void)registerCellsForTableView
{
    OVERRIDE_METHOD
}

@end
