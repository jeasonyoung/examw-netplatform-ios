//
//  RechargeViewController.h
//  NetSchool
//
//  Created by jeasonyoung on 16/1/21.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "PJTableViewController.h"

@class RechargeViewController;

typedef void (^RechargeResultBlock)(RechargeViewController *controller,BOOL isSuccess);

//充值视图控制器
@interface RechargeViewController : PJTableViewController{
    //充值结果回调
    RechargeResultBlock _rechargeResult;
}

//初始化
-(instancetype)initWithRechargeResult:(RechargeResultBlock)result;

@end