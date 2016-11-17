//
//  ViewController.m
//  ePubReader
//
//  Created by XuPeng on 16/11/15.
//  Copyright © 2016年 XP. All rights reserved.
//

#import "ViewController.h"
#import "CoreTextConfig.h"
#import "EPUBParser.h"
#import "CoreTextDisplayView.h"
#import "CoreTextFrameParser.h"
#import "CoreTextPaging.h"

@interface ViewController ()<CoreTextDisplayViewDelegate,UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic, strong) CoreTextDisplayView  *coreTextDisplayView;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIViewController     *currentVC;
@property (nonatomic, strong) UIViewController     *nextVC;

@end

@implementation ViewController {
    
    EPUBParser *_ePubParser;
    NSMutableArray *_catalogArray; // 目录数组
    NSMutableArray *_pageArray; // 分页后数组
    CoreTextConfig *_config;
    NSInteger _currentPage;
    NSInteger _countPage;
    NSInteger _currentChapter;
    UIView *_imageDetail;
    UIImageView *_imageView;
    CGRect _imageRect;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentPage                   = 0;
    _countPage                     = 0;
    _currentChapter                = 0;
    _config                        = [[CoreTextConfig alloc] init];
    
    NSString * _ePubName           = @"与自己对话：曼德拉自传(中信正版)";
    _ePubParser                    = [[EPUBParser alloc] init];
    // 文件地址
    NSArray *searchPaths           = NSSearchPathForDirectoriesInDomains(
                                                                         NSLibraryDirectory,
                                                                         NSUserDomainMask,
                                                                         YES);
    NSString * _unzipPath          = [[NSString alloc] initWithFormat:@"%@/%@",[searchPaths objectAtIndex:0],_ePubName];
    NSString *fileFullPath         = [[NSBundle mainBundle] pathForResource:_ePubName ofType:@"epub" inDirectory:nil];
    
    _catalogArray                  = [_ePubParser epubCatalogWithEpubFile:fileFullPath WithUnzipFolder:_unzipPath];
    _pageArray                     = [self pagingChapter:_currentChapter];
    _currentVC                     = [self createNextViewController:_currentPage countPage:_countPage];
    if (_currentVC) {
        _pageViewController            = [[UIPageViewController alloc] init];
        _pageViewController.delegate   = self;
        _pageViewController.dataSource = self;
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [_pageViewController setViewControllers:@[_currentVC]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:^(BOOL finished) {
                                     }];
    }
}

- (NSMutableArray *)pagingChapter:(NSInteger)currentChapter {
    
    if (currentChapter >= _catalogArray.count) {
        currentChapter = _catalogArray.count - 1;
    }
    NSMutableArray *chapterContentArray = [_ePubParser epubChapterParserWithChapterFile:_catalogArray[currentChapter][@"src"]];
    NSMutableArray *array               = [CoreTextPaging pagingWithChapterContentArr:chapterContentArray WithConfig:_config];
    _countPage                          = array.count;
    return array;
}

- (UIViewController *)createNextViewController:(NSInteger)currentPage countPage:(NSInteger)countPage {
    if (currentPage >= countPage) {
        return _currentVC;
    }
    
    CoreTextData *data                       = [CoreTextFrameParser parseWithChapterContentArr:_pageArray[_currentPage] WithConfig:_config];
    self.coreTextDisplayView                 = [[CoreTextDisplayView alloc] init];
    self.coreTextDisplayView.data            = data;
    self.coreTextDisplayView.delegate        = self;
    self.coreTextDisplayView.frame           = _config.rect;
    self.coreTextDisplayView.backgroundColor = [UIColor clearColor];
    
    UIViewController *viewController         = [[UIViewController alloc] init];
    viewController.view.frame                = [UIScreen mainScreen].bounds;
    viewController.view.backgroundColor      = [UIColor colorWithRed:0.874 green:1.000 blue:0.960 alpha:1.000];
    [viewController.view addSubview:self.coreTextDisplayView];
    return viewController;
}


#pragma mark - CoreTextDisplayViewDelegate
- (void)clickImage:(CoreTextImageData *)imageData {
    
    CGRect imageRect             = imageData.imagePosition;
    CGPoint imagePosition        = imageRect.origin;
    imagePosition.y              = _config.rect.size.height - imageRect.origin.y
    - imageRect.size.height;
    _imageRect                   = CGRectMake(imagePosition.x + _config.rect.origin.x, imagePosition.y + _config.rect.origin.y, imageRect.size.width, imageRect.size.height);
    
    _imageView                   = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imageData.name]];
    _imageView.frame             = _imageRect;
    _imageDetail                 = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _imageDetail.backgroundColor = [UIColor clearColor];
    [_imageDetail addSubview:_imageView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapGestureRecognizer)];
    [_imageDetail addGestureRecognizer:tapGestureRecognizer];
    
    [UIView animateWithDuration:0.3 animations:^{
        _imageDetail.backgroundColor = [UIColor blackColor];
        CGFloat coefficient          = [UIScreen mainScreen].bounds.size.width / _imageView.frame.size.width;
        _imageView.frame             = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _imageView.frame.size.height * coefficient);
        _imageView.center            = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    }];
    
    [self.view addSubview:_imageDetail];
}
- (void)clickLink:(CoreTextLinkData *)linkData {
    NSLog(@"点击连接");
}
- (void)clickBlank:(CGPoint)point {
    
    // 70 和 90 是测量出来的
    CGRect beforeRect     = [UIScreen mainScreen].bounds;
    beforeRect.size.width = 70.0f;
    
    CGRect afterRect      = [UIScreen mainScreen].bounds;
    afterRect.origin.x    = [UIScreen mainScreen].bounds.size.width - 90.0f;
    afterRect.size.width  = 90.0f;
    
    if (CGRectContainsPoint(beforeRect, point)) {
        [_pageViewController setViewControllers:@[_currentVC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        }];
    } else if (CGRectContainsPoint(afterRect, point)) {
        [_pageViewController setViewControllers:@[_currentVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        }];
    }
}

- (void)imageTapGestureRecognizer {
    [UIView animateWithDuration:0.3 animations:^{
        _imageDetail.backgroundColor = [UIColor clearColor];
        _imageView.frame             = _imageRect;
    } completion:^(BOOL finished) {
        [_imageDetail removeFromSuperview];
    }];
}

#pragma mark - UIPageViewControllerDelegate
#pragma mark 翻页开始
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
}

#pragma mark 翻页结束
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
}
#pragma mark - UIPageViewControllerDataSource
#pragma mark 上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    _currentPage--;
    if (_currentPage < 0) {
        // 下一章
        _currentChapter--;
        if (_currentChapter < 0) {
            _currentChapter = 0;
            _currentPage    = 0;
            return _currentVC;
        }
        _pageArray = [self pagingChapter:_currentChapter];
        _currentPage = _pageArray.count - 1;
    }
    _currentVC = [self createNextViewController:_currentPage countPage:_countPage];
    return _currentVC;
}

#pragma mark 下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    _currentPage++;
    if (_currentPage >= _countPage) {
        // 下一章
        _currentChapter++;
        _pageArray = [self pagingChapter:_currentChapter];
        _currentPage = 0;
    }
    _currentVC = [self createNextViewController:_currentPage countPage:_countPage];
    return _currentVC;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
