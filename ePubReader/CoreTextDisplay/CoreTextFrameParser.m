//
//  CoreTextFrameParser.m
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import "CoreTextFrameParser.h"
#import "CoreTextAttributes.h"

@implementation CoreTextFrameParser

+ (CoreTextData *)parseWithChapterContentArr:(NSMutableArray *)chapterContentArr WithConfig:(CoreTextConfig *)config {
    if (!chapterContentArr || chapterContentArr.count <= 0) {
        return nil;
    }
    NSMutableArray *imageArray  = [NSMutableArray array];
    NSMutableArray *linkArray   = [NSMutableArray array];
    NSAttributedString *content = [CoreTextAttributes attributesWithContentArray:chapterContentArr config:config imageArray:imageArray linkArray:linkArray];
    CoreTextData *data          = [self parseAttributedContent:content config:config];
    data.imageArray             = imageArray;
    data.linkArray              = linkArray;
    return data;
}

+ (CoreTextData *)parseAttributedContent:(NSAttributedString *)contentString config:(CoreTextConfig *)config {
    
    // 创建CTFramesetterRef实例
    CTFramesetterRef framesetter      = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentString);
    
    // 获得要绘制的区域的高度
    CGSize restrictSize               = config.rect.size;
    CGSize coreTextSize               = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, restrictSize, nil);
    CGFloat textHeight                = coreTextSize.height;
    
    // 生成 CTFrameRef 实例
    CTFrameRef frame                  = [self createFrameWithFramesetter:framesetter config:config height:textHeight];
    
    // 将生成好的 CTFrameRef 实例和计算好的绘制高度保存到 CoreTextData 实例中，最后返回 CoreTextData 实例
    CoreTextData *data                = [[CoreTextData alloc] init];
    data.ctFrame                      = frame;
    data.height                       = textHeight;
    
    // 释放内存
    CFRelease(frame);
    CFRelease(framesetter);
    return data;
}

#pragma mark 生成CTFrameRef实例
+ (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter
                                  config:(CoreTextConfig *)config
                                  height:(CGFloat)height {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.rect.size.width, config.rect.size.height));
    CTFrameRef frame      = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

@end
