//
//  AccessConfig.m
//  NetSchool
//
//  Created by jeasonyoung on 15/12/17.
//  Copyright © 2015年 TalkWeb. All rights reserved.
//

#import "AccessConfig.h"

#define ACCESS_URL_NAME @"url"
#define ACCESS_TOKEN_NAME @"token"
#define ACCESS_KEY_NAME @"key"
#define ACCESS_COPYRIGHT_NAME @"copyright"
#define ACCESS_RECHARGES_NAME @"recharges"

#define ACCESS_PREFIX @"access-"

//成员变量
@interface AccessConfig(){
    
}
@end

//访问配置实现
@implementation AccessConfig

//
+(instancetype)shared{
    //静态变量
    static AccessConfig *_instance;
    static dispatch_once_t predicate;
    //执行单列构造
    dispatch_once(&predicate, ^{
        //初始化对象
        _instance = [[self alloc] init];
        //加载配置数据
        [_instance loadConfigData];
    });
    return _instance;
}

//加载配置数据
-(void)loadConfigData{
    //
    NSString *accessCfgPath = nil;
    //
    NSArray *arrays = [[NSBundle mainBundle] pathsForResourcesOfType:@"plist" inDirectory:nil];
    NSRange range;
    for(NSString *cfg in arrays){
        if(cfg == nil) continue;
        range = [cfg rangeOfString:ACCESS_PREFIX];
        if(range.location != NSNotFound){
            accessCfgPath = cfg;
            break;
        }
    }
    //
    if(accessCfgPath){
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:accessCfgPath];
        if(dict && dict.count > 0){
            _url = dict[ACCESS_URL_NAME];
            _accessToken = dict[ACCESS_TOKEN_NAME];
            _accesskey = dict[ACCESS_KEY_NAME];
            _copyright = dict[ACCESS_COPYRIGHT_NAME];
            _recharges = dict[ACCESS_RECHARGES_NAME];
        }
    }
}
@end
