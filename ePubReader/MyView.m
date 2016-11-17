//
//  MyView.m
//  ePubReader
//
//  Created by XuPeng on 16/11/17.
//  Copyright © 2016年 XP. All rights reserved.
//

#import "MyView.h"

@implementation MyView

- (void)dealloc {
    NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(self)));
    NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(self)));
    NSLog(@"调用了dealloc");
}

@end
