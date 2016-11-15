//
//  CoreTextFrameParser.h
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextData.h"
#import "CoreTextConfig.h"

@interface CoreTextFrameParser : NSObject

+ (CoreTextData *)parseWithChapterContentArr:(NSMutableArray *)chapterContentArr WithConfig:(CoreTextConfig *)config;

@end
