//
//  CoreTextUtils.h
//  EpubDemo
//
//  Created by XuPeng on 16/11/10.
//  Copyright © 2016年 XP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreTextLinkData.h"
#import "CoreTextData.h"

@interface CoreTextUtils : NSObject

+ (CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data;

+ (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data;


@end
