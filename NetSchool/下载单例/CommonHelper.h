//
//  CommonHelper.h
//  233JuniorSchool
//
//  Created by 周文松 on 13-6-6.
//  Copyright (c) 2013年 长沙 二三三网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonHelper : NSObject

+(float)getProgress:(float)totalSize currentSize:(float)currentSize;

//经文件大小转化成不带单位ied数字
+(float)getFileSizeNumber:(NSString *)size;

//md5加密处理
//+(NSString *)md5Hex:(NSString *)source;

//base64编码
+(NSString *)encodeBase64:(NSString *)source;

//base64解码
+(NSString *)decodeBase64:(NSString *)base64;

//将数组转换为Hex字符串
+(NSString *)toHexWithArray:(NSArray<NSString *> *)data;

//将Hex字符串解析
+(NSArray<NSString *> *)fromHex:(NSString *)hex;

@end
