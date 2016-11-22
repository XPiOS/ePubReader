//
//  EPUBParser.m
//  EpubDemo
//
//  Created by XuPeng on 16/11/2.
//  Copyright © 2016年 XP. All rights reserved.
//

#import "EPUBParser.h"
#import "ZipArchive.h"
#import "GDataXMLNode.h"
#import "NSString+Format.h"

@implementation EPUBParser {
    NSString *_OPFPath;
    NSString *_NCXPath;
    NSString *_coverString;
}

#pragma mark 得到epub相关信息
- (NSMutableDictionary*)epubFileInfoWithEpubFile:(NSString*)epubFilePath WithUnzipFolder:(NSString*)unzipFolder {
    _OPFPath = [self opfFilePathWithEpubFile:epubFilePath WithUnzipFolder:unzipFolder];
    
    NSMutableDictionary *epubInfo = [NSMutableDictionary dictionary];
    NSData *xmlData               = [[NSData alloc] initWithContentsOfFile:_OPFPath];
    if (xmlData) {
        NSError *err                = nil;
        GDataXMLDocument *opfXmlDoc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&err];
        if ([err code] == 0) {
            GDataXMLElement *root  = [opfXmlDoc rootElement];
            NSArray *metadataArray = [root elementsForName:@"metadata"];
            for (GDataXMLElement *metadata in metadataArray) {
                NSArray *childrenArray = [metadata children];
                for (GDataXMLElement *child in childrenArray) {
                    NSString *localName  = [child localName];
                    NSString *content    = [child stringValue];
                    NSRange titleRange   = [localName rangeOfString:@"title"];
                    NSRange creatorRange = [localName rangeOfString:@"creator"];
                    if (titleRange.location != NSNotFound) {
                        epubInfo[@"title"] = content;
                    } else if (creatorRange.location != NSNotFound) {
                        epubInfo[@"creator"] = content;
                    }
                }
            }
        }
    }
    return epubInfo;
}
#pragma mark 得到目录数组
- (NSMutableArray *)epubCatalogWithEpubFile:(NSString *)epubFilePath WithUnzipFolder:(NSString *)unzipFolder {
    
    NSMutableArray *catalogArray = [NSMutableArray array];
    _OPFPath = [self opfFilePathWithEpubFile:epubFilePath WithUnzipFolder:unzipFolder];
    _NCXPath = [self ncxFilePathWithUnzipFolder:unzipFolder];
    
    // 得到封面地址
    NSMutableDictionary *epubInfo = [NSMutableDictionary dictionary];
    NSData *xmlOPFData               = [[NSData alloc] initWithContentsOfFile:_OPFPath];
    if (xmlOPFData) {
        NSError *err                = nil;
        GDataXMLDocument *opfXmlDoc = [[GDataXMLDocument alloc] initWithData:xmlOPFData options:0 error:&err];
        if ([err code] == 0) {
            GDataXMLElement *root           = [opfXmlDoc rootElement];
            // 获取封面
            NSError *errXPath               = nil;
            // 一个协议，遵循这个协议，可以使用一些语法，使搜索更简单（猜测）
            NSDictionary *namespaceMappings = [NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"];
            NSArray* itemsArray = [root nodesForXPath:@"//opf:item" namespaces:namespaceMappings error:&errXPath];
            for (GDataXMLElement *item in itemsArray) {
                NSString *localName  = [[item attributeForName:@"id"] stringValue];
                if ([localName rangeOfString:@"cover"].location != NSNotFound) {
                    _coverString = [[item attributeForName:@"href"] stringValue];
                    if (_coverString && [_coverString length]>0) {
                        NSInteger lastSlash       = [_OPFPath rangeOfString:@"/" options:NSBackwardsSearch].location;
                        NSString *ebookBasePath   = [_OPFPath substringToIndex:(lastSlash +1)];
                        _coverString = [NSString stringWithFormat:@"%@%@", ebookBasePath, _coverString];
                        break;
                    }
                }
            }
        }
    }
    
    NSData *xmlData            = [[NSData alloc] initWithContentsOfFile:_NCXPath];
    if (xmlData) {
        NSError *err                = nil;
        GDataXMLDocument *ncxXmlDoc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&err];
        if ([err code] == 0) {
            GDataXMLElement *root       = [ncxXmlDoc rootElement];
            NSDictionary *dictNameSpace = [NSDictionary dictionaryWithObject:@"http://www.daisy.org/z3986/2005/ncx/" forKey:@"ncx"];
            NSError *errXPath           = nil;
            NSArray *navPoints          = [root nodesForXPath:@"ncx:navMap/ncx:navPoint" namespaces:dictNameSpace error:&errXPath];
            for (GDataXMLElement *navPoint in navPoints) {
                NSArray *textNodes  = [navPoint nodesForXPath:@"ncx:navLabel/ncx:text" namespaces:dictNameSpace error:nil];
                NSString *ncx_text  = @"";
                if ([textNodes count] > 0) {
                    GDataXMLElement *nodeLabel = textNodes[0];
                    ncx_text                   = [nodeLabel stringValue];
                }
                NSArray *contentNodes = [navPoint nodesForXPath:@"ncx:content" namespaces:dictNameSpace error:nil];
                NSString *ncx_src     = @"";
                if ([contentNodes count] > 0) {
                    GDataXMLElement *nodeContent = contentNodes[0];
                    ncx_src                      = [[nodeContent attributeForName:@"ncx:src"] stringValue];
                    NSRange range = [ncx_src rangeOfString:@"html"];
                    if (range.location != NSNotFound) {
                        ncx_src = [ncx_src substringToIndex:range.length + range.location];
                    }
                }
                if (ncx_src.length > 0) {
                    NSInteger lastSlash     = [_OPFPath rangeOfString:@"/" options:NSBackwardsSearch].location;
                    NSString *ebookBasePath = [_OPFPath substringToIndex:(lastSlash +1)];
                    ncx_src                 = [NSString stringWithFormat:@"%@%@", ebookBasePath, ncx_src];
                } else {
                    ncx_src = @"";
                }
                NSMutableDictionary *oneChapter = [NSMutableDictionary dictionary];
                [oneChapter setObject:[ncx_text length] > 0 ? ncx_text:@"" forKey:@"text"];
                [oneChapter setObject:ncx_src forKey:@"src"];
                [catalogArray addObject:oneChapter];
            }
        }
    }
    NSMutableDictionary *dic = catalogArray[0];
    if (![dic[@"src"] isEqualToString:_coverString]) {
        NSMutableDictionary *coverDic = [NSMutableDictionary dictionary];
        coverDic[@"src"]              = _coverString;
        coverDic[@"text"]             = @"封面";
        [catalogArray insertObject:coverDic atIndex:0];
    }
    return catalogArray;
}

#pragma mark 解析章节内容
- (NSMutableArray *)epubChapterParserWithChapterFile:(NSString *)chapterFilePath {
    NSMutableArray *chapterContentArray = [NSMutableArray array];
    
    if ([chapterFilePath rangeOfString:@"html"].location == NSNotFound) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"key"]              = @"img";
        dic[@"content"]          = chapterFilePath;
        [chapterContentArray addObject:dic];
        return chapterContentArray;
    }
    
    NSData *xmlData       = [[NSData alloc] initWithContentsOfFile:chapterFilePath];
    if (xmlData) {
        NSError *err                = nil;
        GDataXMLDocument *opfXmlDoc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&err];
        if ([err code] == 0) {
            GDataXMLElement *root  = [opfXmlDoc rootElement];
            [self addItem:root array:chapterContentArray chapterFilePath:chapterFilePath];
        }
    }
    return chapterContentArray;
}

- (void)addItem:(GDataXMLElement *)element array:(NSMutableArray *)array chapterFilePath:(NSString *)chapterFilePath {
    NSString *content;
    NSString *localName;
    NSArray *elementArray = [element children];
    if (elementArray.count <= 0) {
        localName = [element localName];
        content   = [element stringValue];
        content   = [content formatContentString:content];
        if (content && ![content isEqualToString:@"　　\n"]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"key"]              = localName;
            dic[@"content"]          = content;
            [array addObject:dic];
        }
    }
    for (GDataXMLElement *item in elementArray) {
         localName = [item localName];
        if ([localName isEqualToString:@"head"]) {
            continue;
        } else if ([localName isEqualToString:@"img"]) {
            content                 = [[item attributeForName:@"src"] stringValue];
            NSInteger lastSlash     = [chapterFilePath rangeOfString:@"/" options:NSBackwardsSearch].location;
            NSString *ebookBasePath = [chapterFilePath substringToIndex:(lastSlash +1)];
            content                 = [NSString stringWithFormat:@"%@%@", ebookBasePath, content];
            if (content) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"key"]              = localName;
                dic[@"content"]          = content;
                [array addObject:dic];
            }
        } else if ([localName isEqualToString:@"h1"] || [localName isEqualToString:@"h2"] || [localName isEqualToString:@"h3"]) {
            content = [item stringValue];
            content = [content formatTitleString:content];
            if (content && ![content isEqualToString:@"\n"]) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"key"]              = localName;
                dic[@"content"]          = content;
                [array addObject:dic];
            }
        } else {
            [self addItem:item array:array chapterFilePath:chapterFilePath];
        }
    }
}

#pragma mark 获取ncx文件位置
- (NSString *)ncxFilePathWithUnzipFolder:(NSString *)unzipFolder {

    NSString *ncxFileName = nil;
    NSData *xmlData       = [[NSData alloc] initWithContentsOfFile:_OPFPath];
    if (xmlData) {
        NSError *err                = nil;
        GDataXMLDocument *opfXmlDoc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&err];
        if ([err code] == 0) {
            GDataXMLElement *root           = [opfXmlDoc rootElement];
            NSError *errXPath               = nil;
            // 一个协议，遵循这个协议，可以使用一些语法，使搜索更简单（猜测）
            NSDictionary *namespaceMappings = [NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"];
            NSArray* itemsArray = [root nodesForXPath:@"//opf:item[@id='ncx']" namespaces:namespaceMappings error:&errXPath];
            if ([itemsArray count] < 1) {
                itemsArray = [root nodesForXPath:@"//item[@id='ncx']" namespaces:namespaceMappings error:&errXPath];
            }
            if ([itemsArray count] > 0) {
                GDataXMLElement *element = itemsArray[0];
                NSString *itemhref       = [[element attributeForName:@"href"] stringValue];
                ncxFileName              = itemhref;
            }
        }
    }
    if (ncxFileName && [ncxFileName length]>0) {
        NSInteger lastSlash       = [_OPFPath rangeOfString:@"/" options:NSBackwardsSearch].location;
        NSString *ebookBasePath   = [_OPFPath substringToIndex:(lastSlash +1)];
        NSString *ncxFileFullPath = [NSString stringWithFormat:@"%@%@", ebookBasePath, ncxFileName];
        return ncxFileFullPath;
    }
    return nil;
}

#pragma mark 获取opf文件位置
- (NSString *)opfFilePathWithEpubFile:(NSString*)epubFilePath WithUnzipFolder:(NSString*)unzipFolder {
    
    if (_OPFPath) {
        return _OPFPath;
    }
    NSString *manifestFileFullPath = [NSString stringWithFormat:@"%@%@",unzipFolder,@"/META-INF/container.xml"];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:manifestFileFullPath];
    if (!xmlData) {
        [self unzipWithFileFullPath:epubFilePath WithUnzipFolder:unzipFolder];
    }
    xmlData = [[NSData alloc] initWithContentsOfFile:manifestFileFullPath];
    if (xmlData) {
        NSError *err = nil;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&err];
        if ([err code] == 0) {
            GDataXMLElement *root = [doc rootElement];
            NSArray *nodes = [root nodesForXPath:@"//@full-path[1]" error:nil];
            if ([nodes count]>0) {
                GDataXMLElement *opfNode = nodes[0];
                _OPFPath = [NSString stringWithFormat:@"%@/%@",unzipFolder,[opfNode stringValue]];
            }
        }
    }
    return _OPFPath;
}

#pragma mark 解压epub
- (BOOL)unzipWithFileFullPath:(NSString *)fileFullPath WithUnzipFolder:(NSString *)unzipFolder {
    ZipArchive* za = [[ZipArchive alloc] init];
    if( [za UnzipOpenFile:fileFullPath]) {
        if ([self isFileExist:unzipFolder]) {
            // 目录存在，就删除目录里面所有文件
            [self deleteDirectory:unzipFolder DelSelf:NO];
        } else {
            // 目录不存在，就创建
            [self createDirectory:unzipFolder];
        }
        BOOL bUnZip = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",unzipFolder] overWrite:YES];
        [za UnzipCloseFile];
        return bUnZip;
    }
    return NO;
}
#pragma mark 判断文件夹是否存在
- (BOOL)isFileExist:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}
#pragma mark 删除文件
- (BOOL)deleteDirectory:(NSString*)strFolderPath DelSelf:(BOOL)bDelSelf {
    BOOL bDo1 = YES;
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:strFolderPath];
    NSString *file;
    while (file = [dirEnum nextObject]) {
        NSString *delPath = [strFolderPath stringByAppendingPathComponent:file];
        if (![localFileManager removeItemAtPath:delPath error:nil]) {
            bDo1=NO;
        }
    }
    return bDo1;
}
#pragma mark 创建文件夹
- (BOOL)createDirectory:(NSString*)strFolderPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:strFolderPath]) {
        return [fileManager createDirectoryAtPath:strFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return YES;
}

@end
