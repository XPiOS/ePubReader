//
//  CoreTextAttributes.m
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import "CoreTextAttributes.h"
#import <CoreText/CoreText.h>
#import "CoreTextImageData.h"
#import "CoreTextLinkData.h"

@implementation CoreTextAttributes

+ (NSMutableAttributedString *)attributesWithContentArray:(NSMutableArray *)contentArray
                                                   config:(CoreTextConfig *)config
                                               imageArray:(NSMutableArray *)imageArray
                                                linkArray:(NSMutableArray *)linkArray {
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    NSString *templateFilePath  = [[NSBundle mainBundle] pathForResource:@"CoreTextTemplateFile" ofType:@"json" inDirectory:nil];
    NSData *data = [NSData dataWithContentsOfFile:templateFilePath];
    NSMutableDictionary *templateDic = [NSMutableDictionary dictionary];
    if (data) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in array) {
                templateDic[dic[@"type"]] = dic;
            }
        }
    }
    for (NSMutableDictionary *dic in contentArray) {
        NSString *key = dic[@"key"];
        if ([key isEqualToString:@"link"]) {
            NSString *content                  = dic[@"content"];
            NSMutableDictionary *attributesDic = templateDic[key];
            NSUInteger startPos                = attributedString.length;
            NSAttributedString *as             = [self parseAttributedContentFromNSDictionary:attributesDic config:config contentString:content];
            [attributedString appendAttributedString:as];
            NSUInteger length                  = attributedString.length - startPos;
            NSRange linkRange                  = NSMakeRange(startPos, length);
            CoreTextLinkData *linkData         = [[CoreTextLinkData alloc] init];
            linkData.url                       = content;
            linkData.range                     = linkRange;
            if (linkArray) {
                [linkArray addObject:linkData];
            }
        } else if ([key isEqualToString:@"img"]) {
            NSString *content                  = dic[@"content"];
            CoreTextImageData *imageData       = [[CoreTextImageData alloc] init];
            imageData.name                     = content;
            imageData.position                 = attributedString.length;
            UIImage *image = [UIImage imageWithContentsOfFile:content];
            imageData.rectDic = [NSMutableDictionary dictionary];
            CGFloat coefficient = image.size.height / config.rect.size.height;
            coefficient = coefficient < image.size.width / config.rect.size.width ? image.size.width / config.rect.size.width : coefficient;
            if (coefficient > 1.0f) {
                imageData.rectDic[@"height"] = [NSString stringWithFormat:@"%f",image.size.height /coefficient];
                imageData.rectDic[@"width"]  = [NSString stringWithFormat:@"%f",image.size.width / coefficient];
            } else {
                imageData.rectDic[@"height"] = [NSString stringWithFormat:@"%f",image.size.height];
                imageData.rectDic[@"width"]  = [NSString stringWithFormat:@"%f",image.size.width];
            }
            if (imageArray) {
                [imageArray addObject:imageData];
            }
            // 创建图片占位符，并设置CTRunDelegate
            NSAttributedString *as             = [self parseImageDataFromRectDic:imageData.rectDic config:config];
            [attributedString appendAttributedString:as];
        } else {
            NSString *content                  = dic[@"content"];
            NSMutableDictionary *attributesDic = templateDic[key];
            NSAttributedString *as             = [self parseAttributedContentFromNSDictionary:attributesDic config:config contentString:content];
            [attributedString appendAttributedString:as];
        }
    }
    
    return attributedString;
}
#pragma mark 通过字典得到文本样式
+ (NSAttributedString *)parseAttributedContentFromNSDictionary:(NSDictionary *)dict
                                                        config:(CoreTextConfig *)config
                                                 contentString:(NSString *)contentString {
    
    NSMutableDictionary *attributes = (NSMutableDictionary *)[self attributesWithConfig:config];
    UIColor *color                  = [self colorFromTemplate:dict[@"color"]];
    if (color) {
        attributes[NSForegroundColorAttributeName] = (id)color.CGColor;
    }
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize > 0) {
        UIFont *font                    = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
        attributes[NSFontAttributeName] = font;
    }
    return [[NSAttributedString alloc] initWithString:contentString attributes:attributes];
}

#pragma mark 富文本样式
+ (NSMutableDictionary *)attributesWithConfig:(CoreTextConfig *)config {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    UIFont *font                            = [UIFont fontWithName:@"HelveticaNeue" size:config.fontSize];
    // 段的样式设置
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //行间距
    paragraphStyle.lineSpacing              = font.pointSize / 3;
    paragraphStyle.paragraphSpacing         = font.pointSize * 0.5;
    // 对齐
    paragraphStyle.alignment                = NSTextAlignmentJustified;
    dic[NSParagraphStyleAttributeName] = paragraphStyle;
    dic[NSFontAttributeName] = font;
    return dic;
}
#pragma mark 通过字符串，得到颜色值
+ (UIColor *)colorFromTemplate:(NSString *)name {
    if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    } else if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    } else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    } else {
        return nil;
    }
}

#pragma mark 结构体代理
static CGFloat ascentCallback(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void* ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}

#pragma mark 创建图片文本
+ (NSAttributedString *)parseImageDataFromRectDic:(NSMutableDictionary *)rectDic
                                                config:(CoreTextConfig *)config {
    // 结构体代理
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version                = kCTRunDelegateVersion1;
    callbacks.getAscent              = ascentCallback;
    callbacks.getDescent             = descentCallback;
    callbacks.getWidth               = widthCallback;
    CTRunDelegateRef delegate        = CTRunDelegateCreate(&callbacks, (__bridge void *)(rectDic));
    
    // 使用 0xFFFC 作为空白的占位符
    unichar objectReplacementChar    = 0XFFFC;
    NSString *content                = [NSString stringWithCharacters:&objectReplacementChar length:1];
    // 设置默认文本书型
    NSDictionary *attributes         = [self attributesWithConfig:config];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    // 设置制定位置的代理
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}


@end
