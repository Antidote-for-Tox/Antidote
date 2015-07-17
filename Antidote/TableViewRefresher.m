//
//  TableViewRefresher.m
//  Antidote
//
//  Created by Chuong Vu on 7/17/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "TableViewRefresher.h"

#define LOG_IDENTIFIER self

@interface TableViewRefresher ()

@property (strong, nonatomic) dispatch_source_t timer;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation TableViewRefresher

- (instancetype)initWithTableView:(UITableView *)tableView
{
    NSParameterAssert(tableView);

    AALogVerbose(@"%@", tableView);
    self = [super self];

    if (! self) {
        return nil;
    }

    _tableView = tableView;

    return self;
}

- (void)startTimer
{
    AALogVerbose();
    @synchronized(self) {
        if (self.timer) {
            NSAssert(! self.timer, @"There is already a timer in progress!");
        }

        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        uint64_t interval = NSEC_PER_SEC;
        uint64_t leeway = NSEC_PER_SEC / 1000;
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, interval, leeway);

        __weak TableViewRefresher *weakSelf = self;

        dispatch_source_set_event_handler(self.timer, ^{
            TableViewRefresher *strongSelf = weakSelf;
            if (! strongSelf) {
                dispatch_source_cancel(self.timer);
                AALogError(@"Error: Attempt to update timer with no strong pointer to TableViewRefresher");
                return;
            }

            [strongSelf.tableView reloadData];

            AALogVerbose(@"%@ reloaded", strongSelf.tableView);
        });

        dispatch_resume(self.timer);
    }
}

- (void)stopTimer
{
    AALogVerbose();

    @synchronized(self) {
        if (! self.timer) {
            return;
        }

        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

@end
