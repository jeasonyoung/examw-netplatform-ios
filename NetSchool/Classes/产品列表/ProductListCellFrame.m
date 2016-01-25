//
//  ProductListCellFrame.m
//  NetSchool
//
//  Created by jeasonyoung on 16/1/18.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "ProductListCellFrame.h"
#import "NSObject+CGTool.h"

#define _kProductListCellFrame_top 5//顶部间隔
#define _kProductListCellFrame_bottom 5//底部间隔
#define _kProductListCellFrame_left 5//左边间隔
#define _kProductListCellFrame_right 5//右边间隔

#define _kProductListCellFrame_horizontal 8//水平间距
#define _kProductListCellFrame_vertical 4//垂直间距

#define _kProductListCellFrame_title_fontSize 18//字体
#define _kProductListCellFrame_normal_fontSize 15//字体

//产品列表数据Frame实现
@implementation ProductListCellFrame

#pragma mark - 初始化数据
-(instancetype)initWithData:(ProductModel *)data{
    if((self = [super init]) && data){
        [self setModel:data];
    }
    return self;
}

#pragma mark - 设置产品数据模型
- (void)setModel:(ProductModel *)model{
    _model = model;
    if(!_model) return;
    //
    //
    CGFloat width = DeviceW - _kProductListCellFrame_left - _kProductListCellFrame_right;
    //
    CGFloat x = width/2 + _kProductListCellFrame_horizontal,y = _kProductListCellFrame_top;
    
    //产品名称
    _productName = _model.productName;
    if(_productName){
        _productNameFont = Font(_kProductListCellFrame_title_fontSize);
        CGSize productNameSize = [ProductListCellFrame getSizeWithText:_productName
                                                                  font:_productNameFont
                                                               maxSize:CGSizeMake(width - x, MAXFLOAT)];
        _productNameFrame = CGRectMake(x, y, productNameSize.width, productNameSize.height);
        y = CGRectGetMaxY(_productNameFrame);
    }
    
    //授课教师
    if(_model.teacher){
        y += _kProductListCellFrame_vertical;
        _teacherName = [NSString stringWithFormat:@"%@",_model.teacher];
        _teacherNameFont = Font(_kProductListCellFrame_normal_fontSize);
        CGSize teacherNameSize = [ProductListCellFrame getSizeWithText:_teacherName
                                                                  font:_teacherNameFont
                                                               maxSize:CGSizeMake(width - x, MAXFLOAT)];
        _teacherNameFrame = CGRectMake(x, y, teacherNameSize.width, teacherNameSize.height);
        y = CGRectGetMaxY(_teacherNameFrame);
    }else{
        _teacherNameFrame = CGRectZero;
    }
    
    //使用年份
    CGFloat offsetX_1 = x, offsetY_1 = y, offsetY_2 = y;
    if(_model.useYear > 0){
        offsetY_1 += _kProductListCellFrame_vertical;
        _productUseYear = [NSString stringWithFormat:@"年份:%i", (int)_model.useYear];
        _productUseYearFont = Font(_kProductListCellFrame_normal_fontSize);
        CGSize productUseYearSize = [ProductListCellFrame getSizeWithText:_productUseYear
                                                                    font:_productUseYearFont
                                                                 maxSize:CGSizeMake(width - offsetX_1, MAXFLOAT)];
        _productUseYearFrame = CGRectMake(offsetX_1, offsetY_1, productUseYearSize.width, productUseYearSize.height);
        offsetX_1 = CGRectGetMaxX(_productUseYearFrame);
        offsetY_1 = CGRectGetMaxY(_productUseYearFrame);
    }else{
        _productUseYearFrame = CGRectZero;
    }
    
    //总课时
    if(_model.num > 0){
        if(offsetX_1 > x) offsetX_1 += _kProductListCellFrame_horizontal;
        offsetY_2 += _kProductListCellFrame_vertical;
        _totalClassNum = [NSString stringWithFormat:@"总课时:%i", (int)_model.num];
        _totalClassNumFont = Font(_kProductListCellFrame_normal_fontSize);
        CGSize totalClassNumSize= [ProductListCellFrame getSizeWithText:_totalClassNum
                                                                     font:_totalClassNumFont
                                                                  maxSize:CGSizeMake(width - offsetX_1, MAXFLOAT)];
        offsetX_1 += width - offsetX_1 - totalClassNumSize.width;
         _totalClassNumFrame = CGRectMake(offsetX_1, offsetY_2, totalClassNumSize.width, totalClassNumSize.height);
        offsetY_2 = CGRectGetMaxY(_totalClassNumFrame);
    }else{
        _totalClassNumFrame = CGRectZero;
    }
    y = MAX(offsetY_1, offsetY_2);
    
    //价格
    y += _kProductListCellFrame_vertical;
    _price = [NSString stringWithFormat:@"价格:%.2f", _model.price];
    _priceFont = Font(_kProductListCellFrame_normal_fontSize);
    CGSize priceSize = [ProductListCellFrame getSizeWithText:_price
                                                        font:_priceFont
                                                     maxSize:CGSizeMake(width - x, MAXFLOAT)];
    _priceFrame = CGRectMake(x, y, priceSize.width, priceSize.height);
    //行高
    _rowHeight = CGRectGetMaxY(_priceFrame) + _kProductListCellFrame_bottom;
    
    //产品图片
    CGFloat imgX = _kProductListCellFrame_left,
    imgY = _kProductListCellFrame_top,
    imgW = width/2 - _kProductListCellFrame_right,
    imgH = MAX(offsetY_1, offsetY_2) + priceSize.height/2 - _kProductListCellFrame_top;
    
    imgY += (CGRectGetMaxY(_priceFrame) - imgH)/2;
    
    _productImageUrl = _model.imgUrl;
    _productImageFrame = CGRectMake(imgX,imgY,imgW,imgH);
}

@end