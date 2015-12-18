//
//  CommonHelper.m
//  233JuniorSchool
//
//  Created by 周文松 on 13-6-6.
//  Copyright (c) 2013年 长沙 二三三网络科技有限公司. All rights reserved.
//

#import "CommonHelper.h"

#import <CommonCrypto/CommonDigest.h>

@implementation CommonHelper

+(float)getFileSizeNumber:(NSString *)size
{
    NSInteger indexM=[size rangeOfString:@"M"].location;
    NSInteger indexK=[size rangeOfString:@"K"].location;
    NSInteger indexB=[size rangeOfString:@"B"].location;
    if(indexM<1000)//是M单位的字符串
    {
        return [[size substringToIndex:indexM] floatValue]*1024*1024;
    }
    else if(indexK<1000)//是K单位的字符串
    {
        return [[size substringToIndex:indexK] floatValue]*1024;
    }
    else if(indexB<1000)//是B单位的字符串
    {
        return [[size substringToIndex:indexB] floatValue];
    }
    else//没有任何单位的数字字符串
    {
        return [size floatValue];
    }
}

+(float)getProgress:(float)totalSize currentSize:(float)currentSize
{
    return currentSize/totalSize;
}

//md5加密
+(NSString *)md5Hex:(NSString *)source{
    if(source && source.length > 0){
        const char * original = [source UTF8String];
        
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5(original, strlen(original), digest);
        
        NSMutableString *result = [NSMutableString stringWithCapacity:32];
        
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
            [result appendFormat:@"%02x", (int)digest[i]];
        }
        
        return [result lowercaseString];
    }
    return source;
}

//base64编码
+(NSString *)encodeBase64:(NSString *)source{
    if(source && source.length > 0){
        NSData *data = [source dataUsingEncoding:NSUTF8StringEncoding];
        return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    }
    return source;
}

//base64解码
+(NSString *)decodeBase64:(NSString *)base64{
    if(base64 && base64.length > 0){
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64
                                                           options:NSDataBase64DecodingIgnoreUnknownCharacters];
        return [NSString stringWithUTF8String:[data bytes]];
    }
    return base64;
}

@end
