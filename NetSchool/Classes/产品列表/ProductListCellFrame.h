//
//  ProductListCellFrame.h
//  NetSchool
//
//  Created by jeasonyoung on 16/1/18.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProductModel.h"

//产品列表数据Frame
@interface ProductListCellFrame : NSObject

//产品数据
@property(nonatomic,copy)ProductModel *model;

//产品图片URL
@property(nonatomic,copy,readonly)NSString *productImageUrl;

//产品图片尺寸
@property(nonatomic,assign,readonly)CGRect productImageFrame;


//产品名称
@property(nonatomic,copy,readonly)NSString *productName;

//产品名称字体
@property(nonatomic,copy,readonly)UIFont *productNameFont;

//产品名称尺寸
@property(nonatomic,assign,readonly)CGRect productNameFrame;


//授课教师
@property(nonatomic,copy,readonly)NSString *teacherName;

//授课教师字体
@property(nonatomic,copy,readonly)UIFont *teacherNameFont;

//授课教师尺寸
@property(nonatomic,assign,readonly)CGRect teacherNameFrame;


//总课时
@property(nonatomic,copy,readonly)NSString *totalClassNum;

//总课时字体
@property(nonatomic,copy,readonly)UIFont *totalClassNumFont;

//总课时字体尺寸
@property(nonatomic,assign,readonly)CGRect totalClassNumFrame;



//产品使用年份
@property(nonatomic,copy,readonly)NSString *productUseYear;

//产品使用年份字体
@property(nonatomic,copy,readonly)UIFont *productUseYearFont;

//产品使用年份尺寸
@property(nonatomic,assign,readonly)CGRect productUseYearFrame;


//价格
@property(nonatomic,copy,readonly)NSString *price;

//价格字体
@property(nonatomic,copy,readonly)UIFont *priceFont;

//价格尺寸
@property(nonatomic,assign,readonly)CGRect priceFrame;



//行高
@property(nonatomic,assign,readonly)CGFloat rowHeight;

//初始化
-(instancetype)initWithData:(ProductModel *)data;

@end