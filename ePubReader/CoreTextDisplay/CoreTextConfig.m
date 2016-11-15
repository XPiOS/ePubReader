//
//  CoreTextConfig.m
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import "CoreTextConfig.h"

@implementation CoreTextConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _rect             = CGRectMake(20, 30, [UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.height - 60);
        _fontSize         = 16.0f;
        _lineSpace        = _fontSize / 3;
        _paragraphSpacing = _fontSize / 2;
        _textColor        = [UIColor blackColor];
    }
    return self;
}

@end
