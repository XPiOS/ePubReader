//
//  NSString+Format.m
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import "NSString+Format.h"

#define kStringMaxLength  1024

@implementation NSString (Format)

#pragma mark - 内容文本处理
- (NSString *)formatContentString:(NSString *)string {
    NSString *formatStr = [NSString string];
    // 能不用递归，就不用递归
    while (YES) {
        NSRange range = [string rangeOfString:@"\n"];
        if (range.location == NSNotFound) {
            NSString *paragraphStr = [self processingParagraphContent:string];
            if (paragraphStr.length > 0) {
                formatStr = [NSString stringWithFormat:@"　　%@%@\n",formatStr,paragraphStr];
            }
            break;
        } else {
            NSString *paragraphStr = [self processingParagraphContent:[self processingParagraphContent:[string substringToIndex:range.location + range.length - 1]]];
            if (paragraphStr.length > 0) {
                formatStr = [NSString stringWithFormat:@"　　%@%@\n",formatStr,paragraphStr];
            }
            string = [string substringFromIndex:range.location + range.length];
        }
    }
    return formatStr;
}
#pragma mark - 标题文本处理
- (NSString *)formatTitleString:(NSString *)string {
    NSString *chapterContent = [NSString string];
    // 能不用递归，就不用递归
    while (YES) {
        NSRange range = [string rangeOfString:@"\n"];
        if (range.location == NSNotFound) {
            NSString *paragraphStr = [self processingParagraphContent:string];
            if (paragraphStr.length > 0) {
                chapterContent = [NSString stringWithFormat:@"%@%@\n",chapterContent,paragraphStr];
            }
            break;
        } else {
            NSString *paragraphStr = [self processingParagraphContent:[self processingParagraphContent:[string substringToIndex:range.location + range.length - 1]]];
            if (paragraphStr.length > 0) {
                chapterContent = [NSString stringWithFormat:@"%@%@\n",chapterContent,paragraphStr];
            }
            string = [string substringFromIndex:range.location + range.length];
        }
    }
    return chapterContent;
}

#pragma mark - 处理字符串内容
- (NSString *)processingParagraphContent:(NSString *)paragraphStr {
    // 将字符串拆分成最长为1024的子串
    NSString *paragraphContent = [[NSString alloc] init];
    NSInteger stringPointer    = 0;
    while (YES) {
        NSRange range;
        if (stringPointer + kStringMaxLength > paragraphStr.length) {
            NSString *str    = [paragraphStr substringFromIndex:stringPointer];
            str              = [self stringProcessing:str];
            paragraphContent = [paragraphContent stringByAppendingString:str];
            break;
        } else {
            range.location   = stringPointer;
            range.length     = kStringMaxLength;
            NSString *str    = [paragraphStr substringWithRange:range];
            paragraphContent = [paragraphContent stringByAppendingString:[self stringProcessing:str]];
            stringPointer    += kStringMaxLength;
        }
    }
    return paragraphContent;
}

#pragma mark - 格式化章节内容片段
- (NSString *)stringProcessing:(NSString *)str {

    // 去掉开头空格
    NSString *headStr;
    while (str && str.length >= 1) {
        headStr = [str substringToIndex:1];
        if ([headStr isEqualToString:@"　"] || [headStr isEqualToString:@"\t"] || [headStr isEqualToString:@" "] || [headStr isEqualToString:@"\r"] || [headStr isEqualToString:@"\n"]) {
            str = [str substringFromIndex:1];
        } else {
            break;
        }
    }
    // 去掉结尾空格
    NSString *tailStr;
    while (str && str.length > 1) {
        tailStr = [str substringFromIndex:str.length - 1];
        if ([headStr isEqualToString:@"　"] || [headStr isEqualToString:@"\t"] || [headStr isEqualToString:@" "] || [headStr isEqualToString:@"\r"] || [headStr isEqualToString:@"\n"]) {
            str = [str substringToIndex:str.length - 1];
        } else {
            break;
        }
    }
    return str;
}

@end
