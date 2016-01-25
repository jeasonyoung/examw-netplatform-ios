//
//  ProductModel.m
//  NetSchool
//
//  Created by jeasonyoung on 16/1/18.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "ProductModel.h"

//产品数据模型实现。
@implementation ProductModel

#pragma mark - 初始化数据
-(instancetype)initWithData:(NSDictionary *)dict{
    if((self = [super init]) && dict && [dict count] > 0){
        //产品ID
        _productId = dict[@"id"];
        //产品名称
        _productName = dict[@"name"];
        //是否为套餐
        _isTaocan = NO;
        if(dict[@"type"]){
            _isTaocan = [dict[@"type"] isEqualToString:@"package"];
        }
        //使用年份
        if(dict[@"useYear"]){
            _useYear = [dict[@"useYear"] integerValue];
        }
        //产品图片
        _imgUrl = dict[@"img"];
        //产品描述
        _content = dict[@"content"];
        //授课教师
        _teacher = dict[@"teacherName"];
        //总课时
        if(dict[@"classNum"]){
            _num = [dict[@"classNum"] integerValue];
        }
        //原价
        if(dict[@"oldPrice"]){
            _oldPrice = [dict[@"oldPrice"] floatValue];
        }
        //优惠价
        if(dict[@"price"]){
            _price = [dict[@"price"] floatValue];
        }
    }
    return self;
}

@end