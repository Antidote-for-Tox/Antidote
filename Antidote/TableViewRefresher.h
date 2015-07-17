//
//  TableViewRefresher.h
//  Antidote
//
//  Created by Chuong Vu on 7/17/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewRefresher : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView;
- (void)startTimer;
- (void)stopTimer;
@end
