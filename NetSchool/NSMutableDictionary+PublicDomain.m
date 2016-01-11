//
//  NSMutableDictionary+PublicDomain.m
//  HCTProject
//
//  Created by 周文松 on 14-3-11.
//  Copyright (c) 2014年 talkweb. All rights reserved.
//

#import "NSMutableDictionary+PublicDomain.h"
#import <CommonCrypto/CommonDigest.h>
#import "AccessConfig.h"


@implementation NSMutableDictionary (PublicDomain)


#pragma mark - 公共域
- (void)setPublicDomain{
    AccessConfig *cfg = [AccessConfig shared];
 
    self[@"token"] = cfg.accessToken;
    NSArray* arr = self.allKeys;
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSComparisonResult result = [obj1 compare:obj2];
        return result == NSOrderedDescending;
    }];
    
    
    NSMutableString *sign = [NSMutableString string];
    for (NSString *key in arr){
        id value = [self objectForKey:key];
        if(value == nil || value == [NSNull null]) continue;
        if([value isKindOfClass:[NSString class]]){
            NSString *strValue = [(NSString *)value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(strValue.length == 0) continue;
            if([sign length] > 0) [sign appendString:@"&"];
            [sign appendFormat:@"%@=%@", key, strValue];
        }else if([value isKindOfClass:[NSNumber class]]){
            NSNumber *numValue = (NSNumber *)value;
            if([numValue intValue] == 0 || [numValue boolValue] == NO) continue;
            if([sign length] > 0) [sign appendString:@"&"];
            [sign appendFormat:@"%@=%@", key, numValue];
        }else{
            if([sign length] > 0) [sign appendString:@"&"];
            [sign appendFormat:@"%@=%@", key, value];
        }
    }
    [sign appendFormat:@"%@",cfg.accesskey];
    
    DLog(@"签名前字符串:%@",[sign description]);
    
    self[@"sign"] = md5(sign);
}




NSString *md5(NSString* source){
    NSData *data = [source dataUsingEncoding:NSUTF8StringEncoding];
    //const char *str = [data bytes];

    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)[data length], digest);
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0;i < CC_MD5_DIGEST_LENGTH;i++) {
        [result appendFormat: @"%02x", (int)(digest[i])];
    }
    return [result lowercaseString];
}

/*
- (NSString *) setUuidMd5
{
    NSString * uuIdMd5 = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    return uuIdMd5;
}
 */


@end
