//
//  BaseModel.m
//  BabyStory
//
//  Created by 周文松 on 14-11-18.
//  Copyright (c) 2014年 com.talkweb.BabyStory. All rights reserved.
//

#import "BaseModel.h"
#import <UIKit/UIKit.h>

@implementation BaseModel

//重载
+(void)createData:(NSString *)responseString
          success:(void (^)(id data))success
          failure:(void (^)(NSString *msg, NSString *state))failure{
    
    NSLog(@"%@",responseString);
    
    NSData *data=[responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    BOOL isSuccess = [dict[@"success"] boolValue];
    NSString *msg = dict[@"msg"];
    if(isSuccess){
        if(success)success(dict);
    }else{
        //状态值
        int code = [dict[@"code"] intValue];
        if(code == 1040104){
            //登录界面
            Class class = NSClassFromString(@"LoginViewController");
            id logo = [[class alloc] init];
            //
            UIViewController *rootVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            if(rootVC){
                [rootVC presentViewController:logo animated:YES completion:nil];
            }
        }else{
            failure(msg,@"0");
        }
    }
}
@end