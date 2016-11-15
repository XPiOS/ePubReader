//
//  CoreTextDisplayView.h
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreTextData.h"
#import "CoreTextImageData.h"
#import "CoreTextLinkData.h"

@protocol CoreTextDisplayViewDelegate <NSObject>

@optional
/**
 *  点击图片
 *
 *  @param imageData 图片数据
 */
- (void)clickImage:(CoreTextImageData *)imageData;
/**
 *  点击连接
 *
 *  @param linkData 连接数据
 */
- (void)clickLink:(CoreTextLinkData *)linkData;
/**
 *  点击的不是图片也不是连接
 *
 *  @param point 点击位置
 */
- (void)clickBlank:(CGPoint)point;

@end

@interface CoreTextDisplayView : UIView<UIGestureRecognizerDelegate>


@property (nonatomic, weak) id <CoreTextDisplayViewDelegate> delegate;
@property (nonatomic, strong) CoreTextData * data;


@end
