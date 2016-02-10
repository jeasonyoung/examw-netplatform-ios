//
//  RegisterViewController.m
//  NetSchool
//
//  Created by jeasonyoung on 16/1/7.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "RegisterViewController.h"

#import "RegisterInputView.h"

#define kRegInputAllHeight (44 * 3)//注册输入框的整体高度

@interface RegisterViewController(){
    RegisterInputView *_inputView;
    BOOL _regResult;
}
@end

//学员注册
@implementation RegisterViewController

//重载
-(id)initWithLoginSuccess:(SuccessLoginBlock)success{
    if(self = [super initWithLoginSuccess:success]){
        _regResult = NO;
        [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toplogo.png"]]];
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:[self exitView]];
        [self.navigationItem setLeftBarButtonItem:leftButton];
    }
    return self;
}

-(UIButton *)exitView{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 40);
    [btn setTitle:@"登录" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = Font( 17);
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

//返回
-(void)back{
    [_connection cancel];
    _connection = nil;
    _successLogin(self,_regResult);
}

//重载
-(void)loadView{
    [super loadView];
    self.view.backgroundColor = RGBA(213, 254, 254, 1);
}

//重载
-(void)viewDidLoad{
    [super viewDidLoad];
    //添加注册输入框
    RegisterViewController __weak * safeSelf = self;
    _inputView = [[RegisterInputView alloc] initWithFrame:CGRectMake(kDefaultInset.left * 2,
                                                                     kDefaultInset.top * 5,
                                                                     DeviceW - kDefaultInset.left * 4,
                                                                     kRegInputAllHeight)
                                                  success:^{
                                                      [safeSelf eventWithRegister];
                                                  }];
    [self.view addSubview:_inputView];
    //注册按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(CGRectGetMinX(_inputView.frame) + kDefaultInset.left,
                           CGRectGetMaxY(_inputView.frame) + ScaleH(50),
                           CGRectGetWidth(_inputView.frame) - ScaleW(30),
                           ScaleH(50));
    btn.backgroundColor = CustomBlue;
    [btn setTitle:@" 注 册 " forState:UIControlStateNormal];
    btn.titleLabel.font = FontBold(17);
    [btn addTarget:self action:@selector(eventWithRegister) forControlEvents:UIControlEventTouchUpInside];
    [btn getCornerRadius:5 borderColor:CustomBlue borderWidth:.5 masksToBounds:YES];
    [self.view addSubview:btn];
}

//注册时间处理
-(void)eventWithRegister{
    //检查用户名
    NSString *username = [self getInputValue:_inputView.usernameField];
    if(![self getInputValueValid:_inputView.usernameField
                          Regex:@"^[a-zA-Z0-9\\_]{4,20}$"
                       ErrorMsg:@"4-20个字符（建议用QQ号、手机号，可以是字母、数字或下划线）"]){
        return;
    }
    
    //用户密码
    NSString *pwd = [self getInputValue:_inputView.pwdField];
    if(![self getInputValueValid:_inputView.pwdField
                           Regex:@"^[a-zA-Z0-9]{6,20}$"
                        ErrorMsg:@"密码由6-15位数字、字母组成 "]){
        return;
    }
    //重复密码
    NSString *repwd = [self getInputValue:_inputView.rePwdField];
    if(![self getInputValueValid:_inputView.rePwdField
                           Regex:@"^[a-zA-Z0-9]{6,20}$"
                        ErrorMsg:@"密码由6-15位数字、字母组成 "]){
        return;
    }
    //检查密码是否一致
    if(![pwd isEqualToString:repwd]){
        [self.view makeToast:@"两次密码不一致!" duration:1 position:@"center"];
        [_inputView.pwdField becomeFirstResponder];
        return;
    }
    //真实姓名
//    NSString *realname = [self getInputValue:_inputView.realnameField];
//    if(![self getInputValueValid:_inputView.realnameField
//                           Regex:@"^[\u4e00-\u9fa5]{2,6}$"
//                        ErrorMsg:@"请填写您的真实姓名(中文)"]){
//        return;
//    }
    //手机号码
//    NSString *phone = [self getInputValue:_inputView.phoneField];
//    if(![self getInputValueValid:_inputView.phoneField
//                           Regex:@"^1[3-8][0-9]\\d{8}$"
//                        ErrorMsg:@"手机号码不正确"]){
//        return;
//    }
    //邮箱地址
//    NSString *email = [self getInputValue:_inputView.emailField];
//    if(![self getInputValueValid:_inputView.emailField
//                           Regex:@"^([a-zA-Z0-9]+[_|\\-|\\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\\-|\\.]?)*[a-zA-Z0-9]+\\.[a-zA-Z]{2,3}$"
//                        ErrorMsg:@"邮箱地址格式不正确"]){
//        return;
//    }
    //拼装参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = username;
    params[@"pwd"] = pwd;
    params[@"realname"] = @"ios 组册";
    params[@"phone"] = @"13800138000";
    params[@"email"] = @"ios@app.com";
    params[@"terminal"] = [NSNumber numberWithInt:kTerminal_no];
    [params setPublicDomain];
    //
    DLog(@"%@", params.description);
    //发送数据
    [MBProgressHUD showMessag:Loding_text1 toView:self.view];
    _connection = [BaseModel POST:URL(@"api/m/register")
                        parameter:params
                            class:[BaseModel class]
                          success:^(id data) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              _regResult = YES;
                              [self back];
                          }
                          failure:^(NSString *msg, NSString *status) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [self.view makeToast:msg duration:1 position:@"center"];
                          }];
}

//获取输入值。
-(NSString *)getInputValue:(UITextField *)textField{
    return [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
//格式不正确
-(BOOL)getInputValueValid:(UITextField *)textField
                    Regex:(NSString *)regex
                 ErrorMsg:(NSString *)msg{
    NSString *text = [self getInputValue:textField];
    if(text.length == 0){
        [self.view makeToast:textField.placeholder duration:1 position:@"center"];
        [textField becomeFirstResponder];
        return NO;
    }
    if(regex && regex.length > 0){
        if(!msg || msg.length == 0) msg = textField.placeholder;
        NSRange range = [text rangeOfString:regex options:NSRegularExpressionSearch];
        if(range.location == NSNotFound){
            [self.view makeToast:msg duration:1 position:@"center"];
            [textField becomeFirstResponder];
            return NO;
        }
    }
    return YES;
}



//重载收到内存告警
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
