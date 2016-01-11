//
//  RegisterInputView.m
//  NetSchool
//
//  Created by jeasonyoung on 16/1/8.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "RegisterInputView.h"

#define kRegInputHeight 44//注册输入框高度
#define kRegLableFontSize 17//注册名称字体大小

@implementation RegisterInputView

//重载初始化
-(id)initWithFrame:(CGRect)frame success:(void (^)())success{
    if(self = [super initWithFrame:frame success:success]){
        self.backgroundColor = [UIColor whiteColor];
        //UIColor *borderColor = RGBA(213, 254, 254, 1);
        [self getCornerRadius:5 borderColor:CustomBlack borderWidth:.5 masksToBounds:YES];
        //[self layoutViews];
    }
    return self;
}

//重载布局
-(void)layoutViews{
    //账户
    [self addSubview:self.usernameField];
    //密码
    [self addSubview:self.pwdField];
    //重复密码
    [self addSubview:self.rePwdField];
    //真实姓名
    [self addSubview:self.realnameField];
    //手机号码
    [self addSubview:self.phoneField];
    //邮箱地址
    [self addSubview:self.emailField];
}

//用户名字段
-(BaseTextField *)usernameField{
    if(!_usernameField){
        CGRect frame = CGRectMake(defaultInset.left,
                                  0,
                                  CGRectGetWidth(self.frame) - defaultInset.left * 2,
                                  kRegInputHeight);
        _usernameField = [self createInputFieldWithFrame:frame
                                                   Title:@"用户账号:"
                                             PlaceHolder:@"请输入账号"];
        _usernameField.returnKeyType = UIReturnKeyNext;
        _usernameField.keyboardType = UIKeyboardTypeNamePhonePad;
    }
    return _usernameField;
}

//密码
-(BaseTextField *)pwdField{
    if(!_pwdField){
        _pwdField = [self createInputFieldWithPrevFrame:self.usernameField.frame
                                                  Title:@"用户密码:"
                                            PlaceHolder:@"请输入密码"];
        _pwdField.returnKeyType = UIReturnKeyNext;
        _pwdField.keyboardType = UIKeyboardTypeNamePhonePad;
        _pwdField.secureTextEntry = YES;
    }
    return _pwdField;
}

//重复密码
-(BaseTextField *)rePwdField{
    if(!_rePwdField){
        _rePwdField = [self createInputFieldWithPrevFrame:self.pwdField.frame
                                                    Title:@"重复密码:"
                                              PlaceHolder:@"请输入重复密码"];
        _rePwdField.returnKeyType = UIReturnKeyNext;
        _rePwdField.keyboardType = UIKeyboardTypeNamePhonePad;
        _rePwdField.secureTextEntry = YES;
    }
    return _rePwdField;
}

//真实姓名
-(BaseTextField *)realnameField{
    if(!_realnameField){
        _realnameField = [self createInputFieldWithPrevFrame:self.rePwdField.frame
                                                       Title:@"真实姓名:"
                                                 PlaceHolder:@"请输入用户真实姓名"];
        _realnameField.returnKeyType = UIReturnKeyNext;
        _realnameField.keyboardType = UIKeyboardTypeNamePhonePad;
    }
    return _realnameField;
}

//手机号码
-(BaseTextField *)phoneField{
    if(!_phoneField){
        _phoneField = [self createInputFieldWithPrevFrame:self.realnameField.frame
                                                    Title:@"手机号码:"
                                              PlaceHolder:@"请输入手机号码"];
        _phoneField.returnKeyType = UIReturnKeyNext;
        _phoneField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _phoneField;
}

//邮箱地址
-(BaseTextField *)emailField{
    if(!_emailField){
        _emailField = [self createInputFieldWithPrevFrame:self.phoneField.frame
                                                    Title:@"电子邮箱:"
                                              PlaceHolder:@"请输入电子邮箱地址"];
        _emailField.returnKeyType = UIReturnKeyDone;
        _emailField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    return _emailField;
}

//创建input
-(BaseTextField *)createInputFieldWithPrevFrame:(CGRect)prevFrame
                                          Title:(NSString *)title
                                    PlaceHolder:(NSString *)placeHolder{
    CGRect frame = CGRectMake(CGRectGetMinX(prevFrame),
                              CGRectGetMaxY(prevFrame),
                              CGRectGetWidth(prevFrame),
                              kRegInputHeight);
    return [self createInputFieldWithFrame:frame
                                     Title:title
                               PlaceHolder:placeHolder];
}
//创建input
-(BaseTextField *)createInputFieldWithFrame:(CGRect)frame
                                      Title:(NSString *)title
                                PlaceHolder:(NSString *)placeHolder{
    BaseTextField *textField = [[BaseTextField alloc] initWithFrame:frame];
    textField.placeholder = placeHolder;
    textField.leftView = [self setLeftTitle:title];
    [self setRightRequired:textField];
    textField.delegate = self;
    textField.font = Font(kRegLableFontSize);
    return textField;
}

//必须输入项
-(void)setRightRequired:(UITextField *)textField{
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"*";
    label.textColor = [UIColor redColor];
    [label sizeToFit];
    
    
    textField.rightView = label;
    textField.rightViewMode = UITextFieldViewModeAlways;
}

//重载绘制
-(void)drawRect:(CGRect)rect{
    NSUInteger totals = [self.subviews count];
    CGFloat allHeight = CGRectGetHeight(rect);
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = (CGFloat)allHeight/(int)totals;
    for(NSUInteger i = 1; i < totals; i++){
        //绘制直线
        [self drawRectWithLine:rect
                         start:CGPointMake(0, h * i - .25)
                           end:CGPointMake(w, h * i - .25)
                     lineColor:CustomBlack
                     lineWidth:.5];
    }
}
@end