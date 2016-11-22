//
//  NSString+Format.m
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import "NSString+Format.h"

#define kStringMaxLength  1024

static NSCharacterSet *set;

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
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        set = [NSCharacterSet characterSetWithCharactersInString:@"　 \t\r\n"];
    });
    paragraphStr = [paragraphStr stringByTrimmingCharactersInSet:set];
    return paragraphStr;
}

@end
