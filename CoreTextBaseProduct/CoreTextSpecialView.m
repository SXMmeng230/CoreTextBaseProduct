//
//  CoreTextSpecialView.m
//  CoreTextBaseProduct
//
//  Created by mac on 15/12/30.
//  Copyright © 2015年 孙晓萌. All rights reserved.
//

#import "CoreTextSpecialView.h"
#import <CoreText/CoreText.h>

#import "UIView+Frame.h"
static  NSString *kAtRegularExpression = @"@[\\u4e00-\\u9fa5\\w\\-]+";
static  NSString *kPhoneNumeberRegularExpression =@"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}";
static NSString *kURLRegularExpression = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
static NSString *kPoundSignRegularExpression = @"#([\\u4e00-\\u9fa5\\w\\-]+)#";
static NSString *kEmailRegularExpression = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
static NSString *kEmojiRegularExpression= @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";

#define kRegularExpression(str) [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionUseUnixLineSeparators|NSRegularExpressionCaseInsensitive error:nil]

#define kClickBackViewColor   [UIColor colorWithRed:0/255.0 green:0/255.0  blue:0/255.0  alpha:0.4]
@interface CoreTextSpecialView()

@property (nonatomic, assign) CGFloat textHeight;
@property (nonatomic, assign) CTFrameRef frameRef;
@property (nonatomic, strong) NSMutableArray *valueArray;
@property (nonatomic, assign) NSTextCheckingResult *clickResult;
@property (nonatomic, strong) NSMutableDictionary *syleDictionary;
@property (nonatomic, strong) UIFont *font;
//行间距
@property (nonatomic, assign) CGFloat lineSpaceHeight;
//每一行的高度,这个是根据字体大小动态计算出来的
@property (nonatomic, assign) CGFloat wordHeight;
//表情字典
@property (nonatomic, strong) NSDictionary *emojiDictionary;
@property (nonatomic, strong) NSMutableArray *emojiArray;
@end

@implementation CoreTextSpecialView
#pragma mark - setter-getter
- (NSDictionary *)emojiDictionary
{
    if (_emojiDictionary == nil) {
        NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"expressionImage_custom.plist"];
        _emojiDictionary = [[NSDictionary alloc] initWithContentsOfFile:emojiFilePath];
    }
    return _emojiDictionary;
}
#pragma mark - lift Circle
- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setInit];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setInit];
    }
    return self;
}
- (void)setInit
{
    self.userInteractionEnabled = YES;
    self.font = [UIFont systemFontOfSize:20.0f];
    self.lineSpaceHeight = 10.0f;
}
#pragma mark - 根据点击位置,返回点击结果
- (BOOL)isGestureIndexPoint:(CGPoint)point
{
    //方式一:确定位置
    BOOL isGesture = NO;
    CFArrayRef lines = CTFrameGetLines(self.frameRef);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);
    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);

    for (CFIndex i = 0; i < CFArrayGetCount(lines); i ++) {
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, i);
        CGPoint linePoint = lineOrigins[i];
        CGRect fileRect = CGRectMake(linePoint.x, linePoint.y, self.bounds.size.width, self.font.pointSize);
        CGRect rect = CGRectApplyAffineTransform(fileRect, transform);
        if (CGRectContainsPoint(rect, point)) {
            // 将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),point.y-CGRectGetMinY(rect));
            // 获得当前点击坐标对应的字符串偏移
           CFIndex strIndex = CTLineGetStringIndexForPosition(lineRef, relativePoint);
            for ( NSTextCheckingResult*result in self.valueArray) {
                if (NSLocationInRange(strIndex, result.range)) {
                    self.clickResult = (__bridge NSTextCheckingResult *)(CFRetain((__bridge CFTypeRef)(result)));
                    isGesture = YES;

                }
            }
        }

    }
    return isGesture;
    
    //方式二:确定点击位置
    //        int indexLine = point.y / (self.wordHeight + self.lineSpaceHeight);
    /*
     int indexLine = point.y / (self.font.pointSize + self.lineSpaceHeight);
     CGPoint clickPoint = CGPointMake(point.x,self.textHeight - point.y);
     CFArrayRef lines = CTFrameGetLines(self.frameRef);
     if (indexLine < CFArrayGetCount(lines)) {
     CTLineRef lineRef = CFArrayGetValueAtIndex(lines, indexLine);
     CFIndex strIndex = CTLineGetStringIndexForPosition(lineRef, clickPoint);
     for ( NSTextCheckingResult*result in self.valueArray) {
     if (strIndex >=result.range.location && strIndex <= (result.range.location +result.range.length)) {
     self.clickResult = result;
     isGestureBegin = YES;
     }
     }
     }
     return isGestureBegin;
     */

}
#pragma mark - touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    BOOL isGestur = [self isGestureIndexPoint:[touch locationInView:self]];
    if (isGestur) {
        [self setNeedsDisplay];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.clickResult.range.length != 0)
    {
        NSString *clickStr = [self.text substringWithRange:self.clickResult.range];
        if ([self.delegate respondsToSelector:@selector(clickCoreTextSpecialView:coreText:style:)]) {
            NSNumber *style = [self.syleDictionary objectForKey:self.clickResult];
            [self.delegate clickCoreTextSpecialView:self coreText:clickStr style:(CoreTextSpecial_Style)style.integerValue];
            self.clickResult = nil;
            [self setNeedsDisplay];
        }
    }
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
#pragma mark - drawBackView
- (void)drawBackViewContextRef:(CGContextRef)ctx Rect:(CGRect)rect
{
    //设置笔触颜色
    CGContextSetStrokeColorWithColor(ctx,kClickBackViewColor.CGColor);
    //设置笔触宽度
    CGContextSetLineWidth(ctx, 1);
    //设置填充色
    CGContextSetFillColorWithColor(ctx,kClickBackViewColor.CGColor);
    CGContextAddRect(ctx, rect);
    CGContextFillPath(ctx);
    
}
#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    // Drawing code

    if (self.text.length == 0) {
        return;
    }
    self.textHeight = [self getHeight];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, self.textHeight));
    NSMutableAttributedString *attributedStr = [self getAttributedForText:self.text];
    [self setUpAttributed:attributedStr];
    [self sepcialStringWithAttributed:attributedStr text:self.text];

    //绘制文字
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, self.bounds.size.width, self.textHeight));
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, self.text.length), path, NULL);
//    CTFrameDraw(frameRef, context);
    self.frameRef = CFRetain(frameRef);
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    CGFloat frameY = 0.0;
    for (int i = 0; i < CFArrayGetCount(lines); i ++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        CGPoint lineOrigin = lineOrigins[i];
        //方式一:根据文字计算每个文字的位置
        /*
        self.wordHeight = lineDescent + lineAscent + lineLeading;
        if (i > 0) {
            frameY =  frameY - self.lineSpaceHeight - lineAscent;
            lineOrigin.y = frameY;
        }else{
            frameY = lineOrigin.y;
        }
         */
        //方式二:固定高度计算每个文字的位置
        CGFloat lineHeight = self.font.pointSize;
        frameY = self.textHeight - (i + 1)*(lineHeight) - i * self.lineSpaceHeight - self.font.descender;
        
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line, context);

        //微调高度
        frameY = frameY - lineDescent;
        
        //绘制表情或图片
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
            //点击背景
            if (self.clickResult.range.length != 0) {
                CFIndex strIndex = CTLineGetStringIndexForPosition(line, runRect.origin);
                if (NSLocationInRange(strIndex, self.clickResult.range)) {
                    [self drawBackViewContextRef:context Rect:runRect];
                }
            }
            NSString *imageName = attributes[@"imageStr"];
                UIImage *image = [UIImage imageNamed:imageName];
                if (image) {
                    CGRect imageDrawRect;
                    imageDrawRect.size = image.size;
                    imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x;
                    imageDrawRect.origin.y = lineOrigin.y;
                    //微调Y
                    imageDrawRect.origin.y -= self.lineSpaceHeight * 0.5;
                    CGContextDrawImage(context, imageDrawRect, image.CGImage);
                }
        }
      }
    CFRelease(frameRef);
    CFRelease(framesetterRef);
    CFRelease(path);
}
#pragma mark - 定制特殊文字
- (void)sepcialStringWithAttributed:(NSMutableAttributedString *)attributed text:(NSString *)textStr
{
    self.valueArray= [NSMutableArray array];
    self.syleDictionary = [NSMutableDictionary dictionary];
    NSArray *regexps = @[kRegularExpression(kAtRegularExpression) ,kRegularExpression(kPhoneNumeberRegularExpression),kRegularExpression(kURLRegularExpression),kRegularExpression(kPoundSignRegularExpression),kRegularExpression(kEmailRegularExpression)];
    for (int i = 0; i < regexps.count; i ++) {
    [regexps[i] enumerateMatchesInString:textStr options:NSMatchingWithTransparentBounds range:NSMakeRange(0, textStr.length) usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
        NSRegularExpression *expression = regexps[i];
        UIColor *color = [UIColor redColor];
        if ([expression.pattern isEqualToString:kAtRegularExpression]) {
            [self.syleDictionary setObject:@2 forKey:result];
            color = [UIColor redColor];
        }else if ([expression.pattern isEqualToString:kPhoneNumeberRegularExpression]){
            [self.syleDictionary setObject:@1 forKey:result];
            color = [UIColor blueColor];
        }else if ([expression.pattern isEqualToString:kURLRegularExpression]){
            [self.syleDictionary setObject:@0 forKey:result];
            color = [UIColor greenColor];
        }else if ([expression.pattern isEqualToString:kPoundSignRegularExpression]){
            [self.syleDictionary setObject:@3 forKey:result];
            color = [UIColor purpleColor];
        }else if ([expression.pattern isEqualToString:kEmailRegularExpression]){
            [self.syleDictionary setObject:@4 forKey:result];
            color = [UIColor orangeColor];
        }
        [attributed addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(result.range.location, result.range.length)];
        [self.valueArray addObject:result];
    }];
    }
}
#pragma mark - 返回文本高度
- (CGFloat)getHeight{
    NSMutableAttributedString *attribut = [[NSMutableAttributedString alloc] initWithString:self.text];
    [self setUpAttributed:attribut];
    CTFramesetterRef frameRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attribut);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(frameRef, CFRangeMake(0, self.text.length), NULL, CGSizeMake(self.bounds.size.width, MAXFLOAT), NULL);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, self.bounds.size.width, suggestSize.height));
    CTFrameRef frame = CTFramesetterCreateFrame(frameRef, CFRangeMake(0, self.text.length), pathRef, NULL);
    CFArrayRef lineArray = CTFrameGetLines(frame);
    CFIndex lineCount = CFArrayGetCount(lineArray);
    CGFloat totalHeight = 0.0;
    //方式一: 根据文字动态计算文本总高度
    /*
    CGFloat ascent = 0.0;
    CGFloat deascent = 0.0;
    CGFloat leading = 0.0;
    for (CFIndex i = 0; i < lineCount; i ++) {
        CTLineRef line = CFArrayGetValueAtIndex(lineArray, i);
        CTLineGetTypographicBounds(line, &ascent, &deascent, &leading);
//        totalHeight += ascent + deascent + leading;
    }
     totalHeight += lineCount *self.lineSpaceHeight;
     */
    //方式二: 每行高度固定,计算文本总高度
    totalHeight = lineCount * (self.font.pointSize + self.lineSpaceHeight);
    
    CFRelease(frame);
    CFRelease(pathRef);
    CFRelease(frameRef);
    return  totalHeight;
}
#pragma mark - 设置样式 如:行间距,字体颜色等
- (void)setUpAttributed:(NSMutableAttributedString *)attriStr
{
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = self.lineSpaceHeight;
    paragraph.lineBreakMode = NSLineBreakByCharWrapping;
    [attriStr addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, attriStr.length)];
    [attriStr addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attriStr.length)];
}
#pragma mark - 返回经过处理后的NSMutableAttributedString
- (NSMutableAttributedString *)getAttributedForText:(NSString *)text
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] init];
    self.emojiArray = [NSMutableArray array];
    [kRegularExpression(kEmojiRegularExpression) enumerateMatchesInString:text options:NSMatchingWithTransparentBounds range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        [self.emojiArray addObject:result];
    }];    
    NSInteger index = 0;
    for (NSTextCheckingResult *result in self.emojiArray) {
        NSRange range = result.range;
        NSString *startStr = [text substringWithRange:NSMakeRange(index, range.location - index)];
        NSMutableAttributedString *startAtt = [[NSMutableAttributedString alloc] initWithString:startStr];
        [attributedStr appendAttributedString:startAtt];
        
        NSString *emojiKey = [text substringWithRange:range];
        NSString *imageStr = self.emojiDictionary[emojiKey];
        if (imageStr) {
            NSMutableString *place = [NSMutableString string];
            for (int i = 0 ; i < emojiKey.length; i ++) {
                [place appendFormat:@" "];
            }
            NSMutableAttributedString *imageAtt = [[NSMutableAttributedString alloc] initWithString:place];
            CTRunDelegateCallbacks imageCallBacks;
            imageCallBacks.version =kCTRunDelegateVersion1;
            imageCallBacks.getAscent = RunDelegateGetAscentSpecialCallback;
            imageCallBacks.getDescent = RunDelegateGetDescentSpecialCallback;
            imageCallBacks.getWidth = RunDelegateGetWidthSpecialCallback;
            imageCallBacks.dealloc = RunDelegateDeallocSpecialCallback;
            CTRunDelegateRef runDelegateRef = CTRunDelegateCreate(&imageCallBacks, (__bridge void * _Nullable)(self.font));
            [imageAtt addAttributes:@{(NSString *)kCTRunDelegateAttributeName:(__bridge id)runDelegateRef} range:NSMakeRange(0,1)];
            [imageAtt addAttributes:@{@"imageStr":imageStr} range:NSMakeRange(0,1)];
            [attributedStr appendAttributedString:imageAtt];
            CFRelease(runDelegateRef);

        }else{
            NSMutableAttributedString *textAtt = [[NSMutableAttributedString alloc] initWithString:emojiKey];
            [attributedStr appendAttributedString:textAtt];
        }
        index = range.location + range.length;
    }
    if (index < text.length) {
        NSRange otherRange = NSMakeRange(index, text.length - index);
        NSString *otherText = [text substringWithRange:otherRange];
        NSMutableAttributedString *otherTextAtt = [[NSMutableAttributedString alloc] initWithString:otherText];
        [attributedStr appendAttributedString:otherTextAtt];
    }
    return attributedStr;
}
#pragma mark - 私有方法
void RunDelegateDeallocSpecialCallback( void* refCon ){
    
}
CGFloat RunDelegateGetAscentSpecialCallback (void * refCon){
//    NSString *image = (__bridge NSString *)refCon;
    UIFont *font = (__bridge UIFont *)refCon;
    return font.pointSize * 0.5;
//    return [UIImage imageNamed:image].size.height;
}
CGFloat RunDelegateGetDescentSpecialCallback(void *refCon){
    return 0;
}

CGFloat RunDelegateGetWidthSpecialCallback(void *refCon){
    UIFont *font = (__bridge UIFont *)refCon;
    return font.pointSize * 0.5;
//    NSString *imageName = (__bridge NSString *)refCon;
//    return [UIImage imageNamed:imageName].size.width;
}

@end
