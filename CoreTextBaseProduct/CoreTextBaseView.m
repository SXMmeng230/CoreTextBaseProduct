//
//  CoreTextBaseView.m
//  CoreTextBaseProduct
//
//  Created by mac on 15/12/30.
//  Copyright © 2015年 孙晓萌. All rights reserved.
//

#import "CoreTextBaseView.h"
#import <CoreText/CoreText.h>
#import "UIImageView+WebCache.h"

@interface CoreTextBaseView()
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) UIImage *image;
@end

@implementation CoreTextBaseView
//网络图片下载
- (void)startDownLoadImageURL:(NSString *)url
{
    __weak typeof(self) weakSelf = self;
    
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
      [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageRefreshCached progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
          weakSelf.image = image;
          if (image) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  weakSelf.dictionary = @{@"width":[NSNumber numberWithFloat:image.size.width],@"height":[NSNumber numberWithFloat:image.size.height]};
                  [self setNeedsDisplay];
              });
          }
      }];
  });

}
void RunDelegateDeallocCallback( void* refCon ){
    
}
CGFloat RunDelegateGetAscentCallback (void * refCon){
    NSString *image = (__bridge NSString *)refCon;
    if ([image isKindOfClass:[NSString class]]) {
        return [UIImage imageNamed:image].size.height;
    }
    NSDictionary *dic = (__bridge NSDictionary *)(refCon);
    return [dic[@"height"] floatValue];
}
CGFloat RunDelegateGetDescentCallback(void *refCon){
    return 0;
}

CGFloat RunDelegateGetWidthCallback(void *refCon){
    NSString *imageName = (__bridge NSString *)refCon;
    if ([imageName isKindOfClass:[NSString class]]) {
        return [UIImage imageNamed:imageName].size.width;
    }
    NSDictionary *dic = (__bridge NSDictionary *)(refCon);
    return [dic[@"width"] floatValue];

}
+ (CGFloat)getHeightWithText:(NSString *)aText width:(CGFloat )width
{
    NSMutableAttributedString *attribut = [[NSMutableAttributedString alloc] initWithString:aText];
    CTFramesetterRef frameRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attribut);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(frameRef, CFRangeMake(0, aText.length), NULL, CGSizeMake(width, MAXFLOAT), NULL);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, width, suggestSize.height * 100));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameRef, CFRangeMake(0, aText.length), pathRef, NULL);
    CFArrayRef lineArray = CTFrameGetLines(frame);
    CFIndex lineCount = CFArrayGetCount(lineArray);
    CGFloat ascent = 0;
    CGFloat deascent = 0;
    CGFloat leading = 0;
    CGFloat totalHeight = 0;
    for (CFIndex i = 0; i < lineCount; i ++) {
        CTLineRef line = CFArrayGetValueAtIndex(lineArray, i);
        CTLineGetTypographicBounds(line, &ascent, &deascent, &leading);
        NSLog(@"%g %g %g",ascent,deascent,leading);
        totalHeight += ascent + deascent + leading;
    }
    CFRelease(frame);
    CFRelease(pathRef);
    CFRelease(frameRef);
    return  totalHeight;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context =  UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, self.bounds.size.height));
    NSString *textStr =@"测试富文本富文efef测试富文本富文efefe测试富文本富文本富文efef文本富文efef文本富文efef文本富文efef文本富文13245678 文本富文efef文本富文efef文本富文efef文本富文efef";
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:textStr];
    [attributedStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24]} range:NSMakeRange(0, attributedStr.length)];
    [attributedStr addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]} range:NSMakeRange(0, 2)];
    [attributedStr addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(2, 3)];
    //为图片预览空间
    NSString *imageStr = @"fenmian_donghua10";
    CTRunDelegateCallbacks imageCallBacks;
    imageCallBacks.version =kCTRunDelegateVersion1;
    imageCallBacks.getAscent = RunDelegateGetAscentCallback;
    imageCallBacks.getDescent = RunDelegateGetDescentCallback;
    imageCallBacks.getWidth = RunDelegateGetWidthCallback;
    imageCallBacks.dealloc = RunDelegateDeallocCallback;
//本地图片
    CTRunDelegateRef runDelegateRef = CTRunDelegateCreate(&imageCallBacks, (__bridge void * _Nullable)(imageStr));

    NSMutableAttributedString *imageAttributed = [[NSMutableAttributedString alloc] initWithString:@" "];
    [imageAttributed addAttributes:@{(NSString *)kCTRunDelegateAttributeName:(__bridge id)runDelegateRef} range:NSMakeRange(0, 1)];
    CFRelease(runDelegateRef);
    [imageAttributed addAttributes:@{@"imageStr":imageStr} range:NSMakeRange(0, 1)];
    
    [attributedStr insertAttributedString:imageAttributed atIndex:1];
    
    //网络图片
    NSString *picURL =@"http://weicai-hearsay-avatar.qiniudn.com/b4f71f05a1b7593e05e91b0175bd7c9e?imageView2/2/w/192/h/277";

    CTRunDelegateRef urlImageDelegate = CTRunDelegateCreate(&imageCallBacks, (__bridge void *)self.dictionary);
    NSMutableAttributedString *urlArrtibutedStr = [[NSMutableAttributedString alloc] initWithString:@" "];
    [urlArrtibutedStr addAttributes:@{(NSString *)kCTRunDelegateAttributeName:(__bridge id) urlImageDelegate} range:NSMakeRange(0, 1)];
    CFRelease(urlImageDelegate);
    [attributedStr insertAttributedString:urlArrtibutedStr atIndex:20];
    
    //绘制frame
    CTFramesetterRef cfSetterRef = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)attributedStr);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGRect bounds = CGRectMake(0.0, 0.0, self.bounds.size.width,self.bounds.size.height);
    CGPathAddRect(pathRef, NULL, bounds);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(cfSetterRef,CFRangeMake(0, 0), pathRef, NULL);
    CTFrameDraw(ctFrame, context);
    
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    for (int i = 0; i < CFArrayGetCount(lines); i ++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for (int j = 0; j < CFArrayGetCount(runs); j ++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
            runRect=CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runRect.size.width, runAscent + runDescent);
            NSString *imageName = attributes[@"imageStr"];
            if ([imageName isKindOfClass:[NSString class]]) {
                UIImage *image = [UIImage imageNamed:imageName];
                if (image) {
                    CGRect imageDrawRect;
                    imageDrawRect.size = image.size;
                    imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x;
                    imageDrawRect.origin.y = lineOrigin.y;
                    CGContextDrawImage(context, imageDrawRect, image.CGImage);
                }
            }else{
                imageName = nil;
                CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)([attributes objectForKey:(id)kCTRunDelegateAttributeName]);
                if (!delegate) {
                    continue;
                }
                if (!self.image) {
                    self.image = [UIImage imageNamed:@"fenmian_donghua10"];
                    [self startDownLoadImageURL:picURL];

                }else{
                    CGRect imageDrawRect;
                    imageDrawRect.size = self.image.size;
                    imageDrawRect.origin.x = runRect.origin.x;
                    imageDrawRect.origin.y = lineOrigin.y;
                    CGContextDrawImage(context, imageDrawRect, self.image.CGImage);
                }
            }
        }
    }
    CFRelease(ctFrame);
    CFRelease(pathRef);
    CFRelease(cfSetterRef);
    
}


@end
