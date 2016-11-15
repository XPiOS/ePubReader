//
//  CoreTextImageData.h
//  EpubDemo
//
//  Created by XuPeng on 16/11/9.
//  Copyright © 2016年 XP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoreTextImageData : NSObject

@property (nonatomic, strong) NSString  * name;
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, strong) NSMutableDictionary *rectDic;

// 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
@property (nonatomic, assign) CGRect    imagePosition;

@end
