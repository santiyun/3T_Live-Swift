//
//  TTTUser.m
//  TTTLive
//
//  Created by yanzhen on 2018/8/21.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "TTTUser.h"

@implementation TTTUser
- (instancetype)initWith:(int64_t)uid {
    self = [super init];
    if (self) {
        _uid = uid;
        _clientRole = TTTRtc_ClientRole_Audience;
    }
    return self;
}

- (BOOL)isAnchor {
    return _clientRole == TTTRtc_ClientRole_Anchor;
}
@end
