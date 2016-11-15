//
//  CoreTextData.h
//  EpubDemo
//
//  Created by XuPeng on 16/11/8.
//  Copyright © 2016年 XP. All rights reserved.
//  模型类,持有排版信息

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
@interface CoreTextData : NSObject

@property (nonatomic, assign) CTFrameRef ctFrame;
@property (nonatomic, assign) CGFloat    height;
@property (nonatomic, strong) NSArray    *imageArray;
@property (nonatomic, strong) NSArray    *linkArray;

@end
