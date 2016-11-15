//
//  CoreTextConfig.h
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoreTextConfig : NSObject

@property (nonatomic, assign) CGRect  rect;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, assign) CGFloat paragraphSpacing;
@property (nonatomic, strong) UIColor *textColor;


@end
