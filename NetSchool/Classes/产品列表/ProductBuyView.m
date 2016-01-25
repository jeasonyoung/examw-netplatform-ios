//
//  ProductBuyView.m
//  NetSchool
//
//  Created by jeasonyoung on 16/1/19.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "ProductBuyView.h"
#import "UIView+CGTool.h"
//成员变量
@interface ProductBuyView(){
    
}
@end

//产品购买View实现
@implementation ProductBuyView

#pragma mark - 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setupInitView];
    }
    return self;
}

#pragma mark - 初始化
-(void)setupInitView{
    //背景半透明
    self.backgroundColor = RGBA(160, 160, 160, .6) ;
    //购买按钮
    UIButton *btnBuy = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x = (CGRectGetWidth(self.frame) - kDefaultInset.left - kDefaultInset.right)/2,
    y = kDefaultInset.top,
    w = CGRectGetWidth(self.frame) - x - kDefaultInset.right - 30,
    h = CGRectGetHeight(self.frame) - kDefaultInset.top - kDefaultInset.bottom;
    x += (CGRectGetWidth(self.frame) - x - w)/2;
    btnBuy.frame = CGRectMake(x, y, w, h);
    [btnBuy setTitle:@"立即购买" forState:UIControlStateNormal];
    //[btnBuy setTitleColor:CustomPink forState:UIControlStateNormal];
    btnBuy.titleLabel.font = NFont(18);
    btnBuy.backgroundColor = RGBA(255, 165, 0, .7);//RGBA(186, 59, 119, .7);
    [btnBuy addTarget:self action:@selector(btnBuyClick) forControlEvents:UIControlEventTouchUpInside];
    [btnBuy getCornerRadius:5 borderColor:self.backgroundColor borderWidth:.1 masksToBounds:YES];
    [self addSubview:btnBuy];
}

#pragma mark - 按钮事件处理
-(void)btnBuyClick{
    DLog(@"购买按钮点击...");
    if(_buyDelegate && [_buyDelegate respondsToSelector:@selector(buyWithView:)]){
        [_buyDelegate buyWithView:self];
    }
}
@end
