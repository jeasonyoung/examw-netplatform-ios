//
//  LoginViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/8/28.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//



#import "LoginViewController.h"
#import "LoginInputView.h"
#import "NSString+MD5Addition.h"
#import "AppDelegate.h"
#import "Account.h"
#import "DownloadSinglecase.h"

#import "AccessConfig.h"

#import "RegisterViewController.h"

@interface LoginViewController ()
{
    LoginInputView *_inputView;
}
@end

@implementation LoginViewController

- (id)initWithLoginSuccess:(SuccessLoginBlock)success{
    if((self = [super initWithLoginSuccess:success])){
        [self.navigationItem setNewTitle:@"注 册"];
    }
    return self;
}


- (void)back{
    [_connection cancel];
    _connection = nil;
    _successLogin(self,NO);
}

- (void)loadView{
    [super loadView];
    self.view.backgroundColor = RGBA(213, 254, 254, 1);
}

- (void)viewDidLoad{
    [super viewDidLoad];
  
    NSString *text = [AccessConfig shared].copyright;//@"2006-2015 长沙畅亨信息技术有限公司";
    CGSize size = [NSObject getSizeWithText:text font:FontBold(17) maxSize:CGSizeMake(DeviceW, FontBold(15).lineHeight)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((DeviceW - size.width) / 2, DeviceH - kDefaultInset.bottom * 2 - FontBold(17).lineHeight , size.width, size.height)];
    title.font = FontBold(17);
    title.textColor = RGBA(161, 221, 221, 1);
    title.text = text;
    [self.view addSubview:title];
    
    UIImage *image = [UIImage imageNamed:@"dali_login.png"];
    CGSize imgSize = [NSObject adaptiveWithImage:image maxHeight:DeviceW / 3 * 2 maxWidth:DeviceW / 3 * 2 ];
    UIImageView *logo = [[UIImageView alloc] initWithImage:image];
    logo.frame = CGRectMake((DeviceW - imgSize.width) / 2,  ScaleH(50), imgSize.width, imgSize.height);
    [self.view addSubview:logo];

    LoginViewController __weak*safeSelf = self;
    _inputView = [[LoginInputView alloc] initWithFrame:CGRectMake(kDefaultInset.left * 2,  CGRectGetMaxY(logo.frame) + kDefaultInset.top * 5, DeviceW - kDefaultInset.left * 4, 44 * 2) success:^()
                  {
                      [safeSelf eventWithOnline];
                  }];
    [self.view addSubview:_inputView];

    UIButton *online = [UIButton buttonWithType:UIButtonTypeCustom];
    online.frame = CGRectMake(CGRectGetMinX(_inputView.frame) + kDefaultInset.left, CGRectGetMaxY(_inputView.frame) + ScaleH(50), CGRectGetWidth(_inputView.frame) / 2 - ScaleW(30), ScaleH(50));
    online.backgroundColor = CustomBlue;
    [online setTitle:@"登 录" forState:UIControlStateNormal];
    online.titleLabel.font = Font(17);
    [online addTarget:self action:@selector(eventWithOnline) forControlEvents:UIControlEventTouchUpInside];
    [online getCornerRadius:5 borderColor:CustomBlue borderWidth:.5 masksToBounds:YES];
    [self.view addSubview:online];
    
    //注册
    UIButton *reg = [UIButton buttonWithType:UIButtonTypeCustom];
    reg.frame = CGRectMake(CGRectGetMaxX(online.frame) + ScaleW(60) - kDefaultInset.left * 2, CGRectGetMinY(online.frame), CGRectGetWidth(online.frame), ScaleH(50));
    reg.backgroundColor = CustomGray;
    [reg setTitle:@"注 册" forState:UIControlStateNormal];
    reg.titleLabel.font = Font(17);
    [reg addTarget:self action:@selector(eventWithReg) forControlEvents:UIControlEventTouchUpInside];
    [reg getCornerRadius:5 borderColor:[UIColor  whiteColor] borderWidth:.5 masksToBounds:YES];
    [self.view addSubview:reg];
    
    //游客模式
    CGFloat x = CGRectGetMinX(online.frame),
    y = CGRectGetMaxY(online.frame) + kDefaultInset.top + kDefaultInset.bottom,
    w = CGRectGetMaxX(reg.frame) - x;
    UIButton *visitor = [UIButton buttonWithType:UIButtonTypeCustom];
    visitor.frame = CGRectMake(x, y, w, ScaleH(50));
    [visitor setTitle:@"游客模式 〉" forState:UIControlStateNormal];
    [visitor setTitleColor:CustomBlue forState:UIControlStateNormal];
    [visitor setTitleColor:CustomGray forState:UIControlStateHighlighted];
    visitor.titleLabel.font = Font(17);
    [visitor addTarget:self action:@selector(eventWithVisitor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:visitor];
    
    
}

//学员注册
-(void)eventWithReg{
    RegisterViewController *registerController = [[RegisterViewController alloc] initWithLoginSuccess:^(UIViewController *viewController, BOOL isSuccess) {
        if(isSuccess) [self.view makeToast:@"注册成功!"];
        if([viewController isKindOfClass:[RegisterViewController class]]){
            [(RegisterViewController *)viewController dismissViewController];
        }
    }];
    //[self pushViewController:registerController];
    [self addNavigationWithPresentViewController:registerController];
}

//在线登录
-(void)eventWithOnline{
    //检查网络
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app->_networkStatus == NotReachable){//没有网络
        //本地登录
        [self eventWithLocal];
        return;
    }
    //账号
    NSString *username = [_inputView.accountField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([username length] == 0){
        [self.view makeToast:_inputView.accountField.placeholder duration:1 position:@"center"];
        return;
    }
    //密码
    NSString *password = [_inputView.pwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([password length] == 0){
        [self.view makeToast:_inputView.pwdField.placeholder duration:1 position:@"center"];
        return;
    }
    //远程登录
    [self onlineLoginWithUsername:username pwd:password withIsLogin:YES];
}

#pragma mark - 在线登录
-(void)onlineLoginWithUsername:(NSString *)username pwd:(NSString *)pwd withIsLogin:(BOOL)isLogin{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = username;
    params[@"pwd"] = md5([username stringByAppendingFormat:@"%@",md5(pwd)]);
    params[@"terminal"] = [NSNumber numberWithInt:kTerminal_no];
    [params setPublicDomain];
    //发送数据
    [MBProgressHUD showMessag:Loding_text1 toView:self.view];
    _connection = [BaseModel POST:URL(@"api/m/login")
                        parameter:params
                            class:[BaseModel class]
                          success:^(id data){
                              [self coreDataSave:data[@"data"] withUsername:username isLogin:isLogin];
                              [[DownloadSinglecase sharedDownloadSinglecase] createPath];
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                          }
                          failure:^(NSString *msg, NSString *state){
                              [self.view makeToast:msg duration:1 position:@"center"];
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                          }];

}

//本地登录
-(void)eventWithLocal{
    NSArray *acc = [self coreDataQuery];
    if (!acc.count) {
        [self.view makeToast:@"请先在线登录" duration:1 position:@"center"];
        return;
    }
    Account *model = (Account *)acc[0];
    [Infomation writeInfo:@{@"data":[NSKeyedUnarchiver unarchiveObjectWithData:model.datas],@"userName":_inputView.accountField.text}];
    [kUserDefaults setValue:[NSNumber numberWithBool:YES] forKey:@"isLogin"];
    [kUserDefaults synchronize];
    [[DownloadSinglecase sharedDownloadSinglecase] createPath];

    _successLogin(self,YES);
}

//游客模式
-(void)eventWithVisitor{
    NSString *visitorId = [kUserDefaults objectForKey:@"visitorId"];
    if(visitorId && visitorId.length > 0){//游客ID存在
        [self visitorLoginWithVisitorId:visitorId];
        return;
    }
    //
    //检查网络
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app->_networkStatus == NotReachable){//没有网络
        [self.view makeToast:@"请检查网络～"];
        return;
    }
    
    //创建游客ID
    visitorId = [[NSUUID UUID] UUIDString];
    //md5加密
    visitorId = md5(visitorId);
    //
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = visitorId;
    params[@"pwd"] = visitorId;
    params[@"realname"] = @"游客";
    params[@"phone"] = @"13800138000";
    params[@"email"] = @"ios@iphone.com";
    params[@"terminal"] = [NSNumber numberWithInt:kTerminal_no];
    [params setPublicDomain];
    //
    DLog(@"%@", params.description);
    //发送数据
    [MBProgressHUD showMessag:@"创建游客..." toView:self.view];
    _connection = [BaseModel POST:URL(@"api/m/register")
                        parameter:params
                            class:[BaseModel class]
                          success:^(id data) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              //保存游客
                              [kUserDefaults setValue:visitorId forKey:@"visitorId"];
                              [kUserDefaults synchronize];
                              //游客登录
                              [self visitorLoginWithVisitorId:visitorId];
                          }
                          failure:^(NSString *msg, NSString *status) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              DLog(@"游客注册失败->%@", msg);
                          }];
}
#pragma mark - 游客登录
-(void)visitorLoginWithVisitorId:(NSString *)visitorId{
    DLog(@"游客(%@)登录...", visitorId);
    //检查网络
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app->_networkStatus == NotReachable){//没有网络
        [self.view makeToast:@"请检查网络～"];
        return;
    }
    //游客登录
    [self onlineLoginWithUsername:visitorId pwd:visitorId withIsLogin:NO];
}

-(void)coreDataSave:(id)datas withUsername:(NSString *)username isLogin:(BOOL)isLogin{
    
    if ([self coreDataUpdate:datas]){
        [Infomation writeInfo:@{@"data":datas,@"userName":username}];
        [kUserDefaults setValue:[NSNumber numberWithBool:isLogin] forKey:@"isLogin"];
        [kUserDefaults synchronize];
        _successLogin(self,YES);
        return;
    }
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSError* error=nil;
    
    Account *acc = (Account *)[NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:app.managedObjectContext];
    acc.acc = _inputView.accountField.text;
    acc.pwd = _inputView.pwdField.text;
    acc.datas = [NSKeyedArchiver archivedDataWithRootObject:datas];
    
    BOOL isSaveSuccess=[app.managedObjectContext save:&error];
    if (!isSaveSuccess) {
        NSLog(@"Error:%@",error);
    }else{
        NSLog(@"Save successful!");
    }
    
    [Infomation writeInfo:@{@"data":datas,@"userName":username}];
    [kUserDefaults setValue:[NSNumber numberWithBool:isLogin] forKey:@"isLogin"];
    [kUserDefaults synchronize];
    _successLogin(self,YES);
}

- (NSArray *)coreDataQuery{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    NSFetchRequest* request=[[NSFetchRequest alloc] init]; // 请求数据用的
    
    NSEntityDescription* acc=[NSEntityDescription entityForName:@"Account" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:acc];
         //查询条件
    NSPredicate* accPredicate=[NSPredicate predicateWithFormat:@"acc == %@",_inputView.accountField.text];
    NSPredicate* pwdPredicate=[NSPredicate predicateWithFormat:@"pwd == %@",_inputView.pwdField.text];
    NSPredicate *andCompoundPredicate =[NSCompoundPredicate andPredicateWithSubpredicates:@[accPredicate,pwdPredicate]];

    [request setPredicate:andCompoundPredicate];

    NSError* error=nil;
    NSArray* mutableFetchResult=[app.managedObjectContext executeFetchRequest:request error:&error];

    if (mutableFetchResult == nil){
        NSLog(@"Error:%@",error);
    }
    return mutableFetchResult;
}

- (BOOL)coreDataUpdate:(id)datas{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* user=[NSEntityDescription entityForName:@"Account" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:user];
    //查询条件
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"acc == %@", _inputView.accountField.text];
    [request setPredicate:predicate];
    
    
    NSError* error=nil;
    NSArray* mutableFetchResult=[app.managedObjectContext executeFetchRequest:request error:&error];
   
    if (mutableFetchResult==nil){
        NSLog(@"Error:%@",error);
    }
    NSLog(@"The count of entry: %i",(int)[mutableFetchResult count]);
    //更新age后要进行保存，否则没更新

    for (Account* acc in mutableFetchResult){
        acc.acc = _inputView.accountField.text;
        acc.pwd = _inputView.pwdField.text;
        acc.datas = [NSKeyedArchiver archivedDataWithRootObject:datas];
        [app.managedObjectContext save:&error];
        return YES;
    }
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
