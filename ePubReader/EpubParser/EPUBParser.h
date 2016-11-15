//
//  EPUBParser.h
//  EpubDemo
//
//  Created by XuPeng on 16/11/2.
//  Copyright © 2016年 XP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPUBParser : NSObject

/**
*  得到epub的基本信息，书名、作者等
*
*  @param epubFilePath epub文件位置
*  @param unzipFolder  解压位置
*
*  @return 基本信息字典
*/
- (NSMutableDictionary*)epubFileInfoWithEpubFile:(NSString*)epubFilePath WithUnzipFolder:(NSString*)unzipFolder;

/**
 *  得到目录信息
 *
 *  @param epubFilePath epub文件位置
 *  @param unzipFolder  解压位置
 *
 *  @return 目录数组
 */
- (NSMutableArray*)epubCatalogWithEpubFile:(NSString*)epubFilePath WithUnzipFolder:(NSString*)unzipFolder;

/**
 *  得到章节内容的数组
 *
 *  @param chapterFilePath 章节文件地址
 *
 *  @return 章节内容数组
 */
- (NSMutableArray *)epubChapterParserWithChapterFile:(NSString *)chapterFilePath;

@end
