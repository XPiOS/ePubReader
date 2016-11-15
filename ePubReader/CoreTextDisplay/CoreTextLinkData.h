//
//  CoreTextLinkData.h
//  EpubDemo
//
//  Created by XuPeng on 16/11/10.
//  Copyright © 2016年 XP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreTextLinkData : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) NSRange  range;

@end
