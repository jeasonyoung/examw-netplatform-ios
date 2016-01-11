//
//  ParentModel.m
//  233wangxiaoHD
//
//  Created by 周文松 on 13-12-2.
//  Copyright (c) 2013年 长沙 二三三网络科技有限公司. All rights reserved.
//

#import "ParentModel.h"
@implementation ParentModel

/*GET方法*/
+(void)GET:(NSString *)string
     class:(id)clazz
   success:(void (^)(id data))success
   failure:(void (^)(NSString *msg))failure{
    
    NSLog(@"get-url:%@",string);
    
    [ZWSRequest GET:string
            success:^(NSString *responseString){
                        [clazz createData:responseString
                                  success:^(id data){
                                      if(success){
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              success(data);
                                          });
                                      }
                                      
                                  }
                                  failure:^(NSString *msg, NSString *state){
                                      if(failure){
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              failure(msg);
                                          });
                                      }
                                  }];
            }
            failure:^(NSString* msg){
                if(failure){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failure(msg);
                    });
                }
            }];
}

//
+(void )createData:(NSString *)responseString
           success:(void (^)(id data))success
           failure:(void (^)(NSString *msg, NSString *state))failure{
    
    if(failure)failure(@"请求失败，请联系客服",nil);
}


//post
+(NSURLConnection *)POST:(NSString *)string
               parameter:(id)parameter
                   class:(id)clazz
                 success:(void (^)(id data))success
                 failure:(void (^)(NSString *msg, NSString *status))failure{
    NSLog(@"post-url:%@",string);
    
    return [ZWSRequest POST:string
                  parameter:parameter
                    success:^(NSString *responseString){
                        [clazz createData:responseString
                                  success:^(id data){
                                    if(success)success(data);
                                  }
                                  failure:^(NSString *msg, NSString *status){
                                      if(failure)failure(msg,status);
                                  }];
                    }
                    failure:^( NSString* msg, NSString *status){
                        if(failure)failure(msg,status);
                    }
            ];
}
@end