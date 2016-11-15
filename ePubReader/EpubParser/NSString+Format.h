//
//  NSString+Format.h
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Format)

/**
 *  格式化内容字符串
 *
 *  @param string 需要格式化的字符串
 *
 *  @return 格式化之后的字符串
 */
- (NSString *)formatContentString:(NSString *)string;

/**
 *  格式化标题字符串
 *
 *  @param string 需要格式化的字符串
 *
 *  @return 格式化之后的字符串
 */
- (NSString *)formatTitleString:(NSString *)string;

@end
