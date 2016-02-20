//
//  ProductBuyViewController.m
//  NetSchool
//
//  Created by jeasonyoung on 16/1/20.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "ProductBuyViewController.h"
#import "UIImageView+WebCache.h"
#import "UIView+CGQuartz.h"
#import "UIView+CGTool.h"

#import "LoginGuideViewController.h"
#import "RechargeViewController.h"
#import "RootViewController.h"

#define _kProductBuyInfoView_height 60//
#define _kProductBuyViewController_btnBuy_height 44//购买充值按钮高度

//购买信息View
@interface ProductBuyInfoView : UIView{
    UIImageView *_imgView;
    UILabel *_lbTitle;
    CGFloat _maxHeight, _width;
}
//加载数据
-(void)loadData:(ProductModel *)data;
@end

//购买信息View实现
@implementation ProductBuyInfoView

#pragma mark - 重载初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //
        CGFloat x = kDefaultInset.left, y = kDefaultInset.top;
        _width = (CGRectGetWidth(self.frame) - (kDefaultInset.left + kDefaultInset.right))/2;
        _maxHeight = _kProductBuyInfoView_height;
        //图片
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y,
                            _width - kDefaultInset.right, _maxHeight - kDefaultInset.bottom)];
        //标题
        _lbTitle = [UILabel new];
        _lbTitle.font = Font(18);
        _lbTitle.textColor = CustomBlack;
        //_lbTitle.backgroundColor = CustomAlphaBlue;
        _lbTitle.textAlignment = NSTextAlignmentCenter;
        _lbTitle.numberOfLines = 0;
        _lbTitle.frame = CGRectMake(CGRectGetMaxX(_imgView.frame) + kDefaultInset.left,CGRectGetMinY(_imgView.frame),
                                    _width - kDefaultInset.left,_maxHeight - kDefaultInset.bottom);
        //添加到容器
        [self addSubview:_imgView];
        [self addSubview:_lbTitle];
        CGRect frame = self.frame;
        frame.size.height = _maxHeight + kDefaultInset.bottom;
        self.frame = frame;
        
        //背景
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - 加载数据
-(void)loadData:(ProductModel *)data{
    if(!data)return;
    //图片
    [_imgView sd_setImageWithURL:[NSURL URLWithString:data.imgUrl]];
   
    //标题
    _lbTitle.text = data.productName;
    //
    CGFloat titleW = _width - kDefaultInset.left;
    CGSize titleSize = [ProductBuyInfoView getSizeWithText:_lbTitle.text
                                                      font:_lbTitle.font
                                                   maxSize:CGSizeMake(titleW, MAXFLOAT)];
    if(titleSize.height > _maxHeight){
        _maxHeight = titleSize.height;
        CGRect imgFrame = _imgView.frame;
        imgFrame.size.height = _maxHeight;
        _imgView.frame = imgFrame;
        _lbTitle.frame = CGRectMake(CGRectGetMaxX(_imgView.frame) + kDefaultInset.left,CGRectGetMinY(_imgView.frame),titleW,_maxHeight);
    
        //重置高度
        CGRect frame = self.frame;
        frame.size.height = MAX(CGRectGetMaxY(_imgView.frame), CGRectGetMaxY(_lbTitle.frame))
                    + kDefaultInset.bottom;
        self.frame = frame;
    }
}

#pragma mark 绘制
-(void)drawRect:(CGRect)rect{
   [super drawRect:rect];
    
    //绘制底部线
    CGFloat x1 = kDefaultInset.left, x2 = CGRectGetMaxX(rect) - kDefaultInset.right,y = CGRectGetMaxY(rect);
    [self drawRectWithLine:rect
                     start:CGPointMake(x1, y)
                       end:CGPointMake(x2, y)
                 lineColor:CustomGray
                 lineWidth:.6];
}

@end

//价格View
@interface ProductPriceView : UIView{
    UILabel *_lbPrice,*_lbBalance,*_lbError;
}
//加载数据
-(void)loadData:(ProductModel *)data Balance:(CGFloat)balance;

@end

//价格View实现
@implementation ProductPriceView

#pragma mark - 重载初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //初始化
        _lbPrice = [UILabel new];
        _lbPrice.font = Font(18);
        _lbPrice.textColor = CustomBlack;
        //
        _lbBalance = [UILabel new];
        _lbBalance.font = Font(18);
        _lbBalance.textColor = CustomBlack;
        //
        _lbError = [UILabel new];
        _lbError.textColor = [UIColor redColor];
        _lbError.font = Font(12);
        _lbError.text = @" `_` 您的帐户余额不足!";
        //添加到容器
        [self addSubview:_lbPrice];
        [self addSubview:_lbBalance];
        [self addSubview:_lbError];
        //背景
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - 加载数据
-(void)loadData:(ProductModel *)data Balance:(CGFloat)balance{
    if(!data)return;
    //价格
    NSString *price = [NSString stringWithFormat:@"%.2f", data.price],
        *strPrice = [NSString stringWithFormat:@"价格:%@", price];
    NSMutableAttributedString *priceAttributedText = [[NSMutableAttributedString alloc] initWithString:strPrice
                                                                                            attributes:@{NSFontAttributeName:_lbPrice.font}];
    NSRange priceRange = [strPrice rangeOfString:price];
    if(priceRange.location != NSNotFound){
        [priceAttributedText addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor redColor]
                                    range:priceRange];
    }
    CGFloat x = kDefaultInset.left,y = kDefaultInset.top, w = CGRectGetWidth(self.frame) - kDefaultInset.right;
    CGSize priceSize = [priceAttributedText boundingRectWithSize:CGSizeMake(w - x, MAXFLOAT)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                         context:nil].size;
    _lbPrice.attributedText = priceAttributedText;
    _lbPrice.frame = CGRectMake(x, y, priceSize.width, priceSize.height);
    y = CGRectGetMaxY(_lbPrice.frame) + kDefaultInset.bottom;
    //账户余额
    y += kDefaultInset.top;
    _lbBalance.text = [NSString stringWithFormat:@"账户余额:%.2f", balance];
    CGSize balanceSize = [ProductPriceView getSizeWithText:_lbBalance.text
                                                      font:_lbBalance.font
                                                   maxSize:CGSizeMake(w - x, MAXFLOAT)];
    _lbBalance.frame = CGRectMake(x, y, balanceSize.width, balanceSize.height);
    //
    if(balance < data.price){
        x = CGRectGetMaxX(_lbBalance.frame) + kDefaultInset.right + kDefaultInset.left;
        CGSize size = [ProductPriceView getSizeWithText:_lbError.text
                                                   font:_lbError.font
                                                maxSize:CGSizeMake(w - x, MAXFLOAT)];
        if(size.width + x > w){
            x = kDefaultInset.left;
            y = CGRectGetMaxY(_lbBalance.frame) + kDefaultInset.bottom + kDefaultInset.top;
        }
        //
        y += (CGRectGetHeight(_lbBalance.frame) - size.height)/2;
        _lbError.frame = CGRectMake(x, y, size.width, size.height);
        y = CGRectGetMaxY(_lbError.frame);
    }else{
        y = CGRectGetMaxY(_lbBalance.frame);
        if(_lbError)_lbError.frame = CGRectZero;
    }
    
    //重置高度
    CGRect frame = self.frame;
    frame.size.height = y + kDefaultInset.bottom * 2;
    self.frame = frame;
}

#pragma mark 绘制
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    //绘制底部线
    CGFloat x1 = kDefaultInset.left, x2 = CGRectGetMaxX(rect) - kDefaultInset.right,y = CGRectGetMaxY(rect);
    [self drawRectWithLine:rect
                     start:CGPointMake(x1, y)
                       end:CGPointMake(x2, y)
                 lineColor:CustomGray
                 lineWidth:.6];
}
@end

//产品购买说明View
@interface ProductBuyDescView : UIView{
    UILabel *_lbContent;
}
//加载数据
-(void)loadData;
@end

//产品购买说明View实现
@implementation ProductBuyDescView

#pragma mark - 重载初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //初始化
        _lbContent = [UILabel new];
        _lbContent.font = Font(15);
        _lbContent.textColor = CustomBlack;
        _lbContent.numberOfLines = 0;
        
        //添加到容器
        [self addSubview:_lbContent];
        
        //背景
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - 加载数据
-(void)loadData{
    //内容
    NSMutableString *content = [NSMutableString stringWithString:@"说明\n\n"];
    [content appendString:@"1.iOS App内的充值金额只能在iOS App内使用,不能在其他平台上使用\n\n"];
    [content appendString:@"2.充值金额没有使用期限,会一直保存在您的帐户内\n\n"];
    [content appendString:@"3.充值金额不能退回"];
    _lbContent.text = content;
    //
    CGFloat x = kDefaultInset.left, width = CGRectGetWidth(self.frame) - kDefaultInset.right;
    //
    CGSize size = [ProductBuyDescView getSizeWithText:_lbContent.text
                                                 font:_lbContent.font
                                              maxSize:CGSizeMake(width - x, MAXFLOAT)];
    _lbContent.frame = CGRectMake(x, kDefaultInset.top, width, size.height);
    
    //重置高度
    CGRect frame = self.frame;
    frame.size.height = CGRectGetMaxY(_lbContent.frame) + kDefaultInset.bottom * 2;
    self.frame = frame;
}

#pragma mark 绘制
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    //绘制底部线
    CGFloat x1 = kDefaultInset.left, x2 = CGRectGetMaxX(rect) - kDefaultInset.right,y = CGRectGetMaxY(rect);
    [self drawRectWithLine:rect
                     start:CGPointMake(x1, y)
                       end:CGPointMake(x2, y)
                 lineColor:CustomGray
                 lineWidth:.6];
}

@end


#pragma mark - 成员变量
@interface ProductBuyViewController (){
    ProductModel *_data;
    ProductPriceView *_priceView;
    UIButton *_btnBuy;
    CGFloat _balance;
}
@end

//购买控制器实现
@implementation ProductBuyViewController

#pragma mark - 初始化
-(instancetype)initWithData:(ProductModel *)data{
    if(self = [super init]){
        _data = data;
        //标题
        [self.navigationItem setNewTitle:@"立即购买"];
        [self.navigationItem setBackItemWithTarget:self
                                             title:nil
                                            action:@selector(back)
                                             image:@"back.png"];
        //
        _balance = 0.0f;
    }
    return self;
}

#pragma mark -返回处理
-(void)back{
    if(_connection){
        [_connection cancel];
        _connection = nil;
    }
    [self popViewController];
}

#pragma mark - 重载加载
- (void)viewDidLoad {
    [super viewDidLoad];
    //产品信息
    ProductBuyInfoView *infoView = [[ProductBuyInfoView alloc] initWithFrame:self.view.frame];
    [infoView loadData:_data];
    
    //价格
    CGFloat x = CGRectGetMinX(infoView.frame),
            y = CGRectGetMaxY(infoView.frame) + kDefaultInset.top,
            w = CGRectGetWidth(self.view.frame),
            h = CGRectGetHeight(self.view.frame) - CGRectGetHeight(infoView.frame);
    _priceView = [[ProductPriceView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [_priceView loadData:_data Balance:_balance];
    
    //购买说明
    x = kDefaultInset.left;
    y = CGRectGetMaxY(_priceView.frame) + kDefaultInset.top;
    w = CGRectGetWidth(self.view.frame) - kDefaultInset.left - kDefaultInset.right;
    h = CGRectGetHeight(self.view.frame) - y;
    ProductBuyDescView *descView = [[ProductBuyDescView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [descView loadData];
    
    //购买充值按钮
    _btnBuy = [UIButton buttonWithType:UIButtonTypeCustom];
    y = CGRectGetMaxY(descView.frame) + kDefaultInset.top * 2;
    w -= (kDefaultInset.left + kDefaultInset.right);
    h = _kProductBuyViewController_btnBuy_height;
    _btnBuy.frame = CGRectMake(x, y, w, h);
    _btnBuy.center = CGPointMake(CGRectGetMidX(self.view.frame), y + h/2);
    _btnBuy.titleLabel.font = Font(18);
    [self changeBtnBuy];
    [_btnBuy getCornerRadius:5 borderColor:self.view.backgroundColor borderWidth:.1 masksToBounds:YES];
    [_btnBuy addTarget:self action:@selector(btnBuyClick) forControlEvents:UIControlEventTouchUpInside];
    _btnBuy.enabled = YES;
    
    //添加到容器
    [self.view addSubview:infoView];
    [self.view addSubview:_priceView];
    [self.view addSubview:descView];
    [self.view addSubview:_btnBuy];
    
    //加载用户余额
    [self requestBalanceData];
}

#pragma mark - 更改按钮设置
-(void)changeBtnBuy{
    //校验余额
    BOOL isRecharge = _data.price > _balance;
    _btnBuy.backgroundColor = isRecharge ? RGBA(255, 165, 0, 1) : CustomBlue;
    [_btnBuy setTitle:(isRecharge ? @"立即充值" : @"立即购买") forState:UIControlStateNormal];
}

#pragma mark - 请求帐户余额数据
-(void)requestBalanceData{
    DLog(@"调用服务接口获取余额...");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"randUserId"] = [Infomation readInfo][@"data"][@"randUserId"];
    params[@"terminal"] = @kTerminal_no;
    [params setPublicDomain];
    //提交数据
    [MBProgressHUD showMessag:@"正在帐户余额..." toView:self.view];
    _connection = [BaseModel POST:URL(@"api/m/balance")
                        parameter:params
                            class:[BaseModel class]
                          success:^(id data) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              _balance = [data[@"data"][@"balance"] floatValue];
                              //重新加载价格View数据
                              [_priceView loadData:_data Balance:_balance];
                              //重新更新购买按钮
                              [self changeBtnBuy];
                          }
                          failure:^(NSString *msg, NSString *status) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              //[self.view makeToast:msg];
                          }];
}

#pragma mark - 按钮点击事件
-(void)btnBuyClick{
    if(_data.price > _balance){//检查余额
        if(![self validUserLogin])return;
        [self rechargeHandler];
    }else{
        DLog(@"立即购买...")
        [self productBuy];
    }
}

#pragma mark - 充值处理
-(void)rechargeHandler{
    DLog(@"立即充值...");
    RechargeViewController *controller = [[RechargeViewController alloc] initWithRechargeResult:^(RechargeViewController *controller, BOOL isSuccess) {
        if(controller){
            [controller popViewController];
        }
        if(isSuccess){
            [self requestBalanceData];
            [self makeToast:@"充值成功!"];
        }
    }];
    [self pushViewController:controller];
}

#pragma mark - 产品购买
-(void)productBuy{
    //购买
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"randUserId"] = [Infomation readInfo][@"data"][@"randUserId"];
    params[@"productId"] = _data.productId;
    params[@"type"] = _data.type;
    params[@"terminal"] = @kTerminal_no;
    [params setPublicDomain];
    _btnBuy.enabled = NO;
    //提交数据
    [MBProgressHUD showMessag:@"联系服务器..." toView:self.view];
    _connection = [BaseModel POST:URL(@"api/m/buy")
                        parameter:params
                            class:[BaseModel class]
                          success:^(id data) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [self.view makeToast:@"购买成功，请进入[我的课程]学习!"];
                              [self addNavigationWithPresentViewController:[[RootViewController alloc] init]];
                          }
                          failure:^(NSString *msg, NSString *status) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [self.view makeToast:msg];
                              _btnBuy.enabled = YES;
                          }];
}

#pragma mark - 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 检验是否登录
-(BOOL)validUserLogin{
    if (![[kUserDefaults objectForKey:@"isLogin"] boolValue]){
        [self presentViewController:[[LoginGuideViewController alloc] initWithCallback:^(UIViewController * controller,BOOL result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([controller isKindOfClass:[LoginGuideViewController class]]){
                    [(LoginGuideViewController *)controller dismissViewController];
                }
                if(result){//确定用户
                    [self rechargeHandler];
                }
            });
        }]];
        return NO;
    }
    return YES;
}
@end
