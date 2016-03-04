//
//  LoginGuideViewController.m
//  NetSchool
//
//  Created by jeasonyoung on 16/2/19.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "LoginGuideViewController.h"

/**
 *  登录向导视图控制器成员变量。
 */
@interface LoginGuideViewController (){
    callbackBlock _callbackBlock;
}
@end

/**
 *  登录向导视图控制器实现。
 */
@implementation LoginGuideViewController

-(instancetype)initWithCallback:(callbackBlock)callback{
    if(self = [super init]){
        _callbackBlock = callback;
    }
    return self;
}

- (void)loadView{
    [super loadView];
    self.view.backgroundColor = RGBA(213, 254, 254, 1);
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //图标
    UIImage *image = [UIImage imageNamed:@"dali_login.png"];
    CGSize imgSize = [NSObject adaptiveWithImage:image maxHeight:DeviceW / 3 * 2 maxWidth:DeviceW / 3 * 2 ];
    UIImageView *logo = [[UIImageView alloc] initWithImage:image];
    logo.frame = CGRectMake((DeviceW - imgSize.width) / 2,  ScaleH(50), imgSize.width, imgSize.height);
    [self.view addSubview:logo];
    
    
    CGFloat x = CGRectGetMinX(logo.frame) + kDefaultInset.left,
            y = CGRectGetMaxY(logo.frame) + kDefaultInset.top + kDefaultInset.bottom,
            width = CGRectGetWidth(logo.frame) - kDefaultInset.left - kDefaultInset.right;
    //注册登录
    UIButton *btnRegLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRegLogin.frame = CGRectMake(x, y, width, ScaleH(50));
    [btnRegLogin setTitle:@"注 册 / 登 录" forState:UIControlStateNormal];
    [btnRegLogin setTitleColor:CustomGray forState:UIControlStateHighlighted];
    btnRegLogin.titleLabel.font = Font(20);
    btnRegLogin.backgroundColor = CustomBlue;
    [btnRegLogin addTarget:self action:@selector(eventWithRegLogin) forControlEvents:UIControlEventTouchUpInside];
    [btnRegLogin getCornerRadius:5 borderColor:CustomBlue borderWidth:.5 masksToBounds:YES];
    [self.view addSubview:btnRegLogin];
    

    //游客模式
    y = CGRectGetMaxY(btnRegLogin.frame) + kDefaultInset.top + kDefaultInset.bottom;
    UIButton *btnVisitor = [UIButton buttonWithType:UIButtonTypeCustom];
    btnVisitor.frame = CGRectMake(x, y, width, ScaleH(50));
    [btnVisitor setTitle:@"游客模式充值 〉" forState:UIControlStateNormal];
    [btnVisitor setTitleColor:CustomBlue forState:UIControlStateNormal];
    [btnVisitor setTitleColor:CustomGray forState:UIControlStateHighlighted];
    btnVisitor.titleLabel.font = Font(16);
    [btnVisitor addTarget:self action:@selector(eventWithVisitor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnVisitor];
    
    //说明
    UIFont *font = Font(12);
    y = CGRectGetMaxY(btnVisitor.frame) + kDefaultInset.bottom;
    NSString *text = @"☆ 游客模式模式充值只限于本设备使用，建议您登录后充值!";
    CGSize textSize = [NSObject getSizeWithText:text font:font maxSize:CGSizeMake(width, MAXFLOAT)];
    UILabel *lbDesc = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, textSize.height)];
    lbDesc.font = font;
    lbDesc.textColor = [UIColor redColor];
    lbDesc.text = text;
    lbDesc.numberOfLines = 0;
    [self.view addSubview:lbDesc];
    
}

#pragma mark - 注册/登录事件处理
-(void)eventWithRegLogin{
    [self gotoLogingWithSuccess:^(BOOL isSuccess){
        if (isSuccess){
            [self.view makeToast:@"登录成功"];
            dispatch_async(dispatch_get_main_queue(), ^{
                _callbackBlock(self,YES);
            });
        }
    }class:@"LoginViewController"];
}

#pragma mark - 游客模式事件处理
-(void)eventWithVisitor{
    NSString *visitorId = [kUserDefaults objectForKey:@"visitorId"];
    if(visitorId && visitorId.length > 0){//游客ID存在
        [self visitorLoginWithVisitorId:visitorId];
        return;
    }
}

#pragma mark - 游客登录
-(void)visitorLoginWithVisitorId:(NSString *)visitorId{
    DLog(@"游客(%@)登录...", visitorId);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = visitorId;
    params[@"pwd"] = md5([visitorId stringByAppendingFormat:@"%@",md5(visitorId)]);
    params[@"terminal"] = [NSNumber numberWithInt:kTerminal_no];
    [params setPublicDomain];
    //发送数据
    [MBProgressHUD showMessag:@"游客登录..." toView:self.view];
    _connection = [BaseModel POST:URL(@"api/m/login")
                        parameter:params
                            class:[BaseModel class]
                          success:^(id data){
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              
                              //保存游客用户随机ID
                              [Infomation writeInfo:@{@"data":data[@"data"],@"userName":visitorId}];
                              [kUserDefaults setValue:[NSNumber numberWithBool:NO] forKey:@"isLogin"];
                              [kUserDefaults synchronize];
                              
                              DLog(@"游客用户随机ID=>%@", [Infomation readInfo][@"data"][@"randUserId"]);
                              _callbackBlock(self, YES);
                          }
                          failure:^(NSString *msg, NSString *state){
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              DLog(@"游客登录失败->%@", msg);
                              _callbackBlock(self, NO);
                          }];
    
}

#pragma mark - 内存告警
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end