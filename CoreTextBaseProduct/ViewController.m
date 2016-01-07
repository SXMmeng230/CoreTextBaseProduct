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
    
    //特殊字段 ,表情混排
    CoreTextSpecialView *specialView = [[CoreTextSpecialView alloc] initWithFrame:CGRectMake(50, 100, self.view.bounds.size.width - 100, 0)];
    specialView.backgroundColor = [UIColor grayColor];
    specialView.delegate = self;
    specialView.text =@"#测试富文本#富文 @小萌 😃😁测试富18137270282文本[爱情]富文efefe测试富文本[爱情][爱情][糗大了][爱情]富文本富文efef文本[酷]富文efef文[爱情]本富文efef@明明 富文13723455433文本富文efe[衰]f文本富http://www.baidu.com文ef[糗大了][爱情]ef文本[衰][爱情]富文efef文本富文efe我[篮球]爱你SXMmeng230@163.com哈哈爱你[爱情][爱情][爱情][爱情][糗大了][爱情]爱你哈哈fgvhbjnkm[爱情]lbfeiewn爱你哈哈爱[凋谢]你哈哈[爱情][糗大了]爱你哈哈4567+结束爱你";
    specialView.height = [specialView getHeight];
    [self.view addSubview:specialView];
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
        case CoreTextSpecial_Email_Style:
            NSLog(@"点击邮箱");
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
