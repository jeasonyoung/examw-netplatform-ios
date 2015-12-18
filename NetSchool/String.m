//
//  String.m
//  NetSchool
//
//  Created by 周文松 on 15/8/27.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "String.h"
#import "AccessConfig.h"


@implementation String

+ (NSString *)setUrl:(NSString *)url;{
    
    NSString *serverUrl = [AccessConfig shared].url;
    
    return [serverUrl stringByAppendingString:url];
}

@end