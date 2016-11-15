//
//  CoreTextPaging.m
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import "CoreTextPaging.h"
#import "CoreTextAttributes.h"
#import "CoreTextData.h"

@implementation CoreTextPaging
+ (NSMutableArray *)pagingWithChapterContentArr:(NSMutableArray *)chapterContentArr WithConfig:(CoreTextConfig *)config {
    
    NSMutableArray *pageArray   = [NSMutableArray array];
    NSMutableArray *pagingArray = [NSMutableArray array];
    NSMutableArray *imageArray  = [NSMutableArray array];
    NSMutableArray *linkArray   = [NSMutableArray array];
    
    for ( int chapterContentIndex = 0; chapterContentIndex < chapterContentArr.count; chapterContentIndex++) {
        NSMutableDictionary *dic = chapterContentArr[chapterContentIndex];
        [pagingArray addObject:dic];
        
        CGFloat textHeight = [self pagingWithPagingArray:pagingArray WithConfig:config imageArray:imageArray linkArray:linkArray];
        
        if (textHeight > config.rect.size.height) {
            [pagingArray removeObject:dic];
            NSMutableDictionary *beforeDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            NSMutableDictionary *afterDic  = [NSMutableDictionary dictionaryWithDictionary:dic];
            NSString *content              = dic[@"content"];
            int i                          = 1;
            while (i <= content.length) {
                beforeDic[@"content"]    = [content substringToIndex:i];
                afterDic[@"content"]     = [content substringFromIndex:i];
                [pagingArray addObject:beforeDic];
                CGFloat pagingTextHeight = [self pagingWithPagingArray:pagingArray WithConfig:config imageArray:imageArray linkArray:linkArray];
                if (pagingTextHeight > config.rect.size.height) {
                    beforeDic[@"content"] = [content substringToIndex:i - 1];
                    afterDic[@"content"]  = [content substringFromIndex:i - 1];
                    break;
                } else {
                    i++;
                    [pagingArray removeObject:beforeDic];
                }
            }
            chapterContentArr[chapterContentIndex] = afterDic;
            chapterContentIndex--;
            NSMutableArray *arr                    = [NSMutableArray arrayWithArray:pagingArray];
            [pageArray addObject:arr];
            [pagingArray removeAllObjects];
        }
    }
    if (pagingArray.count > 0) {
        [pageArray addObject:pagingArray];
    }
    
    return pageArray;
}

+ (CGFloat)pagingWithPagingArray:(NSMutableArray *)pagingArray WithConfig:(CoreTextConfig *)config imageArray:(NSMutableArray *)imageArray linkArray:(NSMutableArray *)linkArray {
    NSAttributedString *content  = [CoreTextAttributes attributesWithContentArray:pagingArray config:config imageArray:imageArray linkArray:linkArray];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    CGSize restrictSize          = CGSizeMake(config.rect.size.width, config.rect.size.height + 100);
    CGSize coreTextSize          = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, restrictSize, nil);
    CGFloat textHeight           = coreTextSize.height;
    CFRelease(framesetter);
    return textHeight;
}


@end
