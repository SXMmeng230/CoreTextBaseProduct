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
#define kRegularExpression(str) [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionUseUnixLineSeparators|NSRegularExpressionCaseInsensitive error:nil]
@interface CoreTextSpecialView()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) CGFloat textHeight;
@property (nonatomic, assign) CTFrameRef frameRef;
@property (nonatomic, strong) NSMutableArray *valueArray;
@property (nonatomic, assign) NSTextCheckingResult *clickResult;
@property (nonatomic, strong) NSMutableDictionary *syleDictionary;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat wordHeight;
@end

@implementation CoreTextSpecialView

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:_tapGesture];
        self.font = [UIFont systemFontOfSize:20];
        self.lineHeight = 10.0;
    }
    return self;
}
- (void)tapGes:(UITapGestureRecognizer *)tap
{
    switch (tap.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.clickResult.range.length != 0)
            {
                NSString *clickStr = [self.text substringWithRange:self.clickResult.range];
                if ([self.delegate respondsToSelector:@selector(clickCoreTextSpecialView:coreText:style:)]) {
                    NSNumber *style = [self.syleDictionary objectForKey:self.clickResult];
                    [self.delegate clickCoreTextSpecialView:self coreText:clickStr style:(CoreTextSpecial_Style)style.integerValue];
                }
            }
        }
            break;
        case UIGestureRecognizerStateFailed:
            break;
        default:
            break;
    }
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.tapGesture) {
        BOOL isGestureBegin = NO;
        CGPoint point = [gestureRecognizer locationInView:self];
        CGPoint clickPoint = CGPointMake(point.x,self.textHeight - point.y);
        int indexLine = point.y / (self.wordHeight + self.lineHeight);
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
    }
    return NO;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
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
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:self.text];
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
        NSLog(@"lineAscent = %f",lineAscent);
        NSLog(@"lineDescent = %f",lineDescent);
        NSLog(@"lineLeading = %f",lineLeading);
        NSLog(@"lineOrigin = %@",NSStringFromCGPoint(lineOrigin));
        self.wordHeight = lineDescent + lineAscent + lineLeading;
        NSLog(@"%g  %g",lineDescent + lineAscent + lineLeading,self.font.pointSize);
        
        if (i > 0) {
            frameY =  frameY - self.lineHeight - lineAscent;
            lineOrigin.y = frameY;
        }else{
            frameY = lineOrigin.y;
        }
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line, context);
        //微调高度
        frameY = frameY - lineDescent;
    }
    CFRelease(frameRef);
    CFRelease(framesetterRef);
    CFRelease(path);
}
//定制文字
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
//返回文本高度
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
    CGFloat ascent = 0.0;
    CGFloat deascent = 0.0;
    CGFloat leading = 0.0;
    CGFloat totalHeight = 0.0;
    for (CFIndex i = 0; i < lineCount; i ++) {
        CTLineRef line = CFArrayGetValueAtIndex(lineArray, i);
        CTLineGetTypographicBounds(line, &ascent, &deascent, &leading);
        totalHeight += ascent + deascent + leading;
    }
    totalHeight += lineCount * self.lineHeight;
    CFRelease(frame);
    CFRelease(pathRef);
    CFRelease(frameRef);
    return  totalHeight;
}
//设置样式 如:行间距,字体颜色等
- (void)setUpAttributed:(NSMutableAttributedString *)attriStr
{
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = self.lineHeight;
    paragraph.lineBreakMode = NSLineBreakByCharWrapping;
    [attriStr addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, attriStr.length)];
    [attriStr addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attriStr.length)];
}

@end
