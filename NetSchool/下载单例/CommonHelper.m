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

+(float)getFileSizeNumber:(NSString *)size{
    NSInteger indexM=[size rangeOfString:@"M"].location;
    NSInteger indexK=[size rangeOfString:@"K"].location;
    NSInteger indexB=[size rangeOfString:@"B"].location;
    if(indexM != NSNotFound){//是M单位的字符串
        return [[size substringToIndex:indexM] floatValue]*1024*1024;
    }else if(indexK != NSNotFound){//是K单位的字符串
        return [[size substringToIndex:indexK] floatValue]*1024;
    }else if(indexB != NSNotFound){//是B单位的字符串
        return [[size substringToIndex:indexB] floatValue];
    }else{//没有任何单位的数字字符串
        return [size floatValue];
    }
}

+(float)getProgress:(float)totalSize currentSize:(float)currentSize{
    return currentSize/totalSize;
}

//md5加密
//+(NSString *)md5Hex:(NSString *)source{
//    if(source && source.length > 0){
//        const char * original = [source UTF8String];
//        
//        unsigned char digest[CC_MD5_DIGEST_LENGTH];
//        CC_MD5(original, strlen(original), digest);
//        
//        NSMutableString *result = [NSMutableString stringWithCapacity:32];
//        
//        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
//            [result appendFormat:@"%02x", (int)digest[i]];
//        }
//        
//        return [result lowercaseString];
//    }
//    return source;
//}

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

//将数组转换为Hex字符串
+(NSString *)toHexWithArray:(NSArray<NSString *> *)array{
    if(array && array.count > 0){
        NSString *source = [array componentsJoinedByString:@"$"];
        if(source.length > 60){
            source = [source substringWithRange:NSMakeRange(0, 60)];
        }
        NSData *data = [source dataUsingEncoding:NSUTF8StringEncoding];
        char *chars = (char *)data.bytes;
        if(chars){
            NSUInteger len = data.length;
            NSMutableString *hex = [NSMutableString string];
            for(NSUInteger i = 0; i < len; i++){
                [hex appendFormat:@"%0.2hhx", chars[i]];
            }
            return hex.uppercaseString;
        }
    }
    return nil;
}

//将Hex字符串解析
+(NSArray<NSString *> *)fromHex:(NSString *)hex{
    if(hex && hex.length > 0 && (hex.length % 2  == 0)){
        NSMutableData *data = [NSMutableData data];
        char byte_char[3] = {'\0','\0','\0'};
        NSUInteger len = hex.length / 2;
        for(NSUInteger i = 0; i < len; i++){
            byte_char[0] = [hex characterAtIndex:(i*2)];
            byte_char[1] = [hex characterAtIndex:(i*2 + 1)];
            long byte = strtol(byte_char, NULL, 16);
            [data appendBytes:&byte length:1];
        }
        NSString *source = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
        if(source && source.length > 0){
            return [source componentsSeparatedByString:@"$"];
        }
    }
    return nil;
}
@end
