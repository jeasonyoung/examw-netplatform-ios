//
//  RegisterInputView.h
//  NetSchool
//
//  Created by jeasonyoung on 16/1/8.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "BaseInputView.h"

//学员注册
@interface RegisterInputView : BaseInputView

//用户名
@property(nonatomic,strong)BaseTextField *usernameField;
//密码
@property(nonatomic,strong)BaseTextField *pwdField;
//重复密码
@property(nonatomic,strong)BaseTextField *rePwdField;
////真实姓名
//@property(nonatomic,strong)BaseTextField *realnameField;
////手机号码
//@property(nonatomic,strong)BaseTextField *phoneField;
////邮箱地址
//@property(nonatomic,strong)BaseTextField *emailField;

@end
