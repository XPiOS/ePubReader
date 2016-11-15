//
//  CoreTextAttributes.h
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextConfig.h"

@interface CoreTextAttributes : NSObject

+ (NSMutableAttributedString *)attributesWithContentArray:(NSMutableArray *)contentArray
                                                   config:(CoreTextConfig *)config
                                               imageArray:(NSMutableArray *)imageArray
                                                linkArray:(NSMutableArray *)linkArray;

@end
