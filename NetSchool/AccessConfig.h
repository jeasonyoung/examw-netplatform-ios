//
//  AccessConfig.h
//  NetSchool
//
//  Created by jeasonyoung on 15/12/17.
//  Copyright © 2015年 TalkWeb. All rights reserved.
//

#import <Foundation/Foundation.h>

//访问配置接口
@interface AccessConfig : NSObject

//单列
+(instancetype)shared;

//服务器地址
@property(nonatomic,retain,readonly)NSString *url;

//访问令牌
@property(nonatomic,retain,readonly)NSString *accessToken;

//访问密钥
@property(nonatomic,retain,readonly)NSString *accesskey;

//版权信息
@property(nonatomic,retain,readonly)NSString *copyright;

@end