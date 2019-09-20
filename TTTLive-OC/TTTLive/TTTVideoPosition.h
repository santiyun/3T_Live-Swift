//
//  TTTVideoPosition.h
//  TTTLive
//
//  Created by yanzhen on 2018/8/21.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTTVideoPosition : NSObject
@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double w;
@property (nonatomic, assign) double h;
@property (nonatomic, readonly) int row;
@property (nonatomic, readonly) int column;
@end
