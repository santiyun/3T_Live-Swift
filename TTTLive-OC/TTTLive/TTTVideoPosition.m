//
//  TTTVideoPosition.m
//  TTTLive
//
//  Created by yanzhen on 2018/8/21.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "TTTVideoPosition.h"

@implementation TTTVideoPosition
- (int)row {
    return (int)round((1-_y)/_h);
}

- (int)column {
    return (int)round((_x+_w)/_w);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"row: %d, column: %d", self.row, self.column];
}
@end
