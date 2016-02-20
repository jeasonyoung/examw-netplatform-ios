//
//  LoginGuideViewController.h
//  NetSchool
//
//  Created by jeasonyoung on 16/2/19.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "PJViewController.h"

typedef void(^callbackBlock)(UIViewController *,BOOL);
/**
 *  登录向导视图控制器。
 */
@interface LoginGuideViewController : PJViewController

-(instancetype)initWithCallback:(callbackBlock)callback;

@end