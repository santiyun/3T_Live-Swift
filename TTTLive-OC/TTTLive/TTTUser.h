//
//  TTTUser.h
//  TTTLive
//
//  Created by yanzhen on 2018/8/21.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTTUser : NSObject
@property (nonatomic, assign) int64_t uid;
@property (nonatomic, assign) BOOL mutedSelf; //是否静音
@property (nonatomic, assign) TTTRtcClientRole clientRole;
@property (nonatomic, readonly) BOOL isAnchor;

- (instancetype)initWith:(int64_t)uid;
@end
