//
//  ProductListCell.m
//  NetSchool
//
//  Created by jeasonyoung on 16/1/19.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "ProductListCell.h"
#import "NSObject+CGTool.h"
#import "UIImageView+WebCache.h"

//产品cell成员变量
@interface ProductListCell (){
    UIImageView *_imgView;
    UILabel *_lbProductName,*_lbTeacherName,*_lbTotalClassNum,*_lbProductUseYear,*_lbPrice;
}
@end

//产品Cell实现
@implementation ProductListCell

#pragma mark - 初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupInitControls];
    }
    return self;
}

#pragma mark - 初始化控件
-(void)setupInitControls{
    //1.图片
    _imgView = [UIImageView new];
    
    //2.产品名称
    _lbProductName = [UILabel new];
    _lbProductName.textColor = CustomBlack;
    _lbProductName.numberOfLines = 0;
    
    //3.授课教师
    _lbTeacherName = [UILabel new];
    _lbTeacherName.textColor = CustomBlack;
    _lbTeacherName.numberOfLines = 0;
    
    //4.总课时
    _lbTotalClassNum = [UILabel new];
    _lbTotalClassNum.textColor = CustomBlack;
    _lbTotalClassNum.numberOfLines = 0;
    
    //5.使用年份
    _lbProductUseYear = [UILabel new];
    _lbProductUseYear.textColor = CustomBlack;
    _lbProductUseYear.numberOfLines = 0;
    
    //6.价格
    _lbPrice = [UILabel new];
    _lbPrice.textColor = CustomPink;
    _lbPrice.numberOfLines = 0;
    
    //添加到容器
    [self.contentView addSubview:_imgView];
    [self.contentView addSubview:_lbProductName];
    [self.contentView addSubview:_lbTeacherName];
    [self.contentView addSubview:_lbTotalClassNum];
    [self.contentView addSubview:_lbProductUseYear];
    [self.contentView addSubview:_lbPrice];
}

#pragma mark - 加载数据
-(void)loadDataWithCellFrame:(ProductListCellFrame *)cellFrame{
    DLog(@"状态数据...");
    if(!cellFrame)return;
    
    //1.图片
    _imgView.frame = cellFrame.productImageFrame;
    [_imgView sd_setImageWithURL:[NSURL URLWithString:cellFrame.productImageUrl]];
    
    //2.产品名称
    _lbProductName.frame = cellFrame.productNameFrame;
    _lbProductName.font = cellFrame.productNameFont;
    _lbProductName.text = cellFrame.productName;
    
    //3.授课教师
    _lbTeacherName.frame = cellFrame.teacherNameFrame;
    _lbTeacherName.font = cellFrame.teacherNameFont;
    _lbTeacherName.text = cellFrame.teacherName;
    
    //4.总课时
    _lbTotalClassNum.frame = cellFrame.totalClassNumFrame;
    _lbTotalClassNum.font = cellFrame.totalClassNumFont;
    _lbTotalClassNum.text = cellFrame.totalClassNum;
    
    //5.使用年份
    _lbProductUseYear.frame = cellFrame.productUseYearFrame;
    _lbProductUseYear.font = cellFrame.productUseYearFont;
    _lbProductUseYear.text = cellFrame.productUseYear;
    
    //6.价格
    _lbPrice.frame = cellFrame.priceFrame;
    _lbPrice.font = cellFrame.priceFont;
    _lbPrice.text = cellFrame.price;
}

@end