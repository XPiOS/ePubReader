//
//  CoreTextDisplayView.m
//  EpubDemo
//
//  Created by XuPeng on 16/11/14.
//  Copyright © 2016年 XP. All rights reserved.
//

#import "CoreTextDisplayView.h"
#import "CoreTextUtils.h"

@implementation CoreTextDisplayView

- (id)init {
    self = [super init];
    if (self) {
        [self setupEvents];
    }
    return self;
}

- (void)setupEvents {
    UIGestureRecognizer * tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(userTapGestureDetected:)];
    tapRecognizer.delegate = self;
    [self addGestureRecognizer:tapRecognizer];
    self.userInteractionEnabled = YES;
}

- (void)userTapGestureDetected:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    for (CoreTextImageData * imageData in self.data.imageArray) {
        // 翻转坐标系，因为 imageData 中的坐标是 CoreText 的坐标系
        CGRect imageRect      = imageData.imagePosition;
        CGPoint imagePosition = imageRect.origin;
        imagePosition.y       = self.bounds.size.height - imageRect.origin.y
        - imageRect.size.height;
        CGRect rect           = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
        if (CGRectContainsPoint(rect, point)) {
            if ([self.delegate respondsToSelector:@selector(clickImage:)]) {
                [self.delegate clickImage:imageData];
                return;
            }
        }
    }
    
    CoreTextLinkData *linkData = [CoreTextUtils touchLinkInView:self atPoint:point data:self.data];
    if (linkData) {
        if ([self.delegate respondsToSelector:@selector(clickLink:)]) {
            [self.delegate clickLink:linkData];
            return;
        }
    }
    if ([self.delegate respondsToSelector:@selector(clickBlank:)]) {
        [self.delegate clickBlank:point];
    }
    return;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if (self.data) {
        CTFrameDraw(self.data.ctFrame, context);
    }
    for (CoreTextImageData * imageData in self.data.imageArray) {
        UIImage *image = [UIImage imageNamed:imageData.name];
        if (image) {
            CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
        }
    }
}

@end
