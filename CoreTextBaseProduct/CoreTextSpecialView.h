//
//  CoreTextSpecialView.h
//  CoreTextBaseProduct
//
//  Created by mac on 15/12/30.
//  Copyright © 2015年 孙晓萌. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CoreTextSpecialView;
typedef NS_ENUM (NSInteger,CoreTextSpecial_Style){
    CoreTextSpecial_URL_Style =0, //网址
    CoreTextSpecial_Phone_Style, //手机号
    CoreTextSpecial_At_Style,  //@人名
    CoreTextSpecial_Space_Style, //话题
    CoreTextSpecial_Email_Style //邮件
};
@protocol CoreTextSpecialViewDelegate <NSObject>

- (void)clickCoreTextSpecialView:(CoreTextSpecialView *)view coreText:(NSString *)text style:(CoreTextSpecial_Style)style;

@end
@interface CoreTextSpecialView : UIView<UIGestureRecognizerDelegate>
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) id <CoreTextSpecialViewDelegate>delegate;
- (CGFloat)getHeight;
@end
