//
//  ViewController.m
//  CoreTextBaseProduct
//
//  Created by mac on 15/12/30.
//  Copyright © 2015年 孙晓萌. All rights reserved.
//

#import "ViewController.h"
#import "CoreTextBaseView.h"
#import "CoreTextSpecialView.h"
#import "UIView+Frame.h"

@interface ViewController ()<CoreTextSpecialViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图文混排";
    //图文混排
//    CoreTextBaseView *textView = [[CoreTextBaseView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    [self.view addSubview:textView];
    
    //特殊字段
    CoreTextSpecialView *specialView = [[CoreTextSpecialView alloc] initWithFrame:CGRectMake(50, 100, self.view.bounds.size.width - 100, 0)];
    specialView.backgroundColor = [UIColor grayColor];
    specialView.delegate = self;
    specialView.text =@"#测试富文本#富文 @小萌 😃😁测试富18137270282文本富文efefe测试富文本富文本富文efef文本富文efef文本富文efef@明明 富文13723455433文本富文efef文本富http://baidu.com文efef文本富文efef文本富文efe我爱你哈哈爱你爱你哈哈fgvhbjnkmlbfeiewn爱你哈哈爱你哈哈爱你哈哈4567+结束";
    [self.view addSubview:specialView];
    specialView.height = [specialView getHeight];
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark - CoreTextSpecialViewDelegate
- (void)clickCoreTextSpecialView:(CoreTextSpecialView *)view coreText:(NSString *)text style:(CoreTextSpecial_Style)style
{
    switch (style) {
        case CoreTextSpecial_At_Style:
            NSLog(@"点击人名");
            break;
        case CoreTextSpecial_Phone_Style:
            NSLog(@"点击电话号码");
            break;
        case CoreTextSpecial_Space_Style:
            NSLog(@"点击话题");
            break;
        case CoreTextSpecial_URL_Style:
            NSLog(@"点击网址");
            break;
        default:
            break;
    }
    NSLog(@"%@",text);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
