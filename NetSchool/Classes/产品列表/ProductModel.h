//
//  ProductModel.h
//  NetSchool
//
//  Created by jeasonyoung on 16/1/18.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 产品数据模型。
 */
@interface ProductModel : NSObject

/**
 * @brief 产品ID。
 */
@property(nonatomic,copy,readonly)NSString *productId;

/**
 * @brief 产品名称。
 */
@property(nonatomic,copy,readonly)NSString *productName;

/**
 * @brief 是否为套餐。
 */
@property(nonatomic,assign,readonly)BOOL isTaocan;

/**
 * @brief 使用年份。
 */
@property(nonatomic,assign,readonly)NSUInteger useYear;

/**
 * @brief 产品图片URL。
 */
@property(nonatomic,copy,readonly)NSString *imgUrl;

/**
 * @brief 描述信息。
 */
@property(nonatomic,copy,readonly)NSString *content;

/**
 * @brief 授课教师。
 */
@property(nonatomic,copy,readonly)NSString *teacher;

/**
 * @brief 总课时。
 */
@property(nonatomic,assign,readonly)NSUInteger num;

/**
 * @brief 原价。
 */
@property(nonatomic,assign,readonly)CGFloat oldPrice;

/**
 * @brief 优惠价。
 */
@property(nonatomic,assign,readonly)CGFloat price;

//初始化数据。
-(instancetype)initWithData:(NSDictionary *)dict;

@end