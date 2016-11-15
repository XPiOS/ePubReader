//
//  CoreTextPaging.h
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextConfig.h"

@interface CoreTextPaging : NSObject

+ (NSMutableArray *)pagingWithChapterContentArr:(NSMutableArray *)chapterContentArr WithConfig:(CoreTextConfig *)config;

@end
