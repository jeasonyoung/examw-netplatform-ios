//
//  ProductDetailView.m
//  NetSchool
//
//  Created by jeasonyoung on 16/1/19.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "ProductDetailView.h"
#import "UIImageView+WebCache.h"
#import "NSObject+CGTool.h"

#define _kProductDetailView_imgHeight 120//
#define _kProductDetailView_normal_fontSize 17//字体
//成员变量
@interface ProductDetailView (){
    UIImageView *_imgView;
    UILabel *_lbFirst,*_lbSecond;
}
@end

//产品明细View实现
@implementation ProductDetailView

#pragma mark - 加载数据
-(void)loadData:(ProductModel *)data{
    if(!data)return;
    CGFloat width = CGRectGetWidth(self.frame),
    x = kDefaultInset.left, y = kDefaultInset.top;
    
    //1.图片w/h = 4/3
    if(data.imgUrl){
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,width,_kProductDetailView_imgHeight)];
        [_imgView sd_setImageWithURL:[NSURL URLWithString:data.imgUrl]];
        [self addSubview:_imgView];
        
        y = CGRectGetMaxY(_imgView.frame) + kDefaultInset.bottom;
    }
    width -= kDefaultInset.right;
    //第一行数据
    NSString *teacher = nil, *totals = nil, *useYear = nil;
    if(data.teacher) teacher = [NSString stringWithFormat:@"主讲:%@", data.teacher];
    if(data.num > 0) totals = [NSString stringWithFormat:@"%i课时", (int)data.num];
    if(data.useYear > 0) useYear = [NSString stringWithFormat:@"年份:%i", (int)data.useYear];
    NSMutableString *strFirst = [NSMutableString string];
    if(teacher)[strFirst appendFormat:@"%@  ", teacher];
    if(totals)[strFirst appendFormat:@"%@  ", totals];
    if(useYear)[strFirst appendString:useYear];
    //
    //第一行
    _lbFirst = [UILabel new];
    _lbFirst.font = Font(_kProductDetailView_normal_fontSize);
    _lbFirst.textColor = CustomBlack;
    _lbFirst.numberOfLines = 0;
    _lbFirst.text = strFirst;
    //
    CGSize size = [ProductDetailView getSizeWithText:_lbFirst.text
                                                font:_lbFirst.font
                                             maxSize:CGSizeMake(width - x, MAXFLOAT)];
    _lbFirst.frame = CGRectMake(x, y, width, size.height);
    [self addSubview:_lbFirst];
    y = CGRectGetMaxY(_lbFirst.frame) + kDefaultInset.bottom;
    
    
    //描述信息
    NSString *content = data.content;
    if(content)
        content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(content && content.length > 0){
        UILabel *lbContent = [UILabel new];
        lbContent.font = Font(_kProductDetailView_normal_fontSize);
        lbContent.textColor = CustomBlack;
        lbContent.textAlignment = NSTextAlignmentCenter;
        lbContent.numberOfLines = 0;
        lbContent.text = content;
        
        size = [ProductDetailView getSizeWithText:lbContent.text
                                             font:lbContent.font
                                          maxSize:CGSizeMake(width - x, MAXFLOAT)];
        lbContent.frame = CGRectMake(x, y, width, size.height);
        [self addSubview:lbContent];
        y = CGRectGetMaxY(lbContent.frame) + kDefaultInset.bottom;
    }
    
    //第二行
    NSString *oldPrice = nil, *price = nil;
    if(data.oldPrice > 0 && data.oldPrice != data.price)
        oldPrice = [NSString stringWithFormat:@"原价:%.2f", data.oldPrice];
    if(data.price > 0) price = [NSString stringWithFormat:@"优惠价:%.2f", data.price];
    NSMutableString *strSecond = [NSMutableString string];
    if(oldPrice)[strSecond appendFormat:@"%@  ", oldPrice];
    if(price)[strSecond appendFormat:@"%@ ", price];
    if(strSecond.length > 0){
        _lbSecond = [UILabel new];
        _lbSecond.font = Font(_kProductDetailView_normal_fontSize);
        _lbSecond.textColor = CustomBlack;
        _lbSecond.textAlignment = NSTextAlignmentRight;
        _lbSecond.numberOfLines = 0;
        
        //
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:strSecond];
        //字体处理
        [attributedText addAttribute:NSFontAttributeName
                               value:_lbSecond.font
                               range:NSMakeRange(0, strSecond.length)];
        //原价处理
        if(oldPrice && oldPrice.length > 0){
            NSRange range = [strSecond rangeOfString:oldPrice];
            if(range.location != NSNotFound){
                [attributedText addAttributes:@{NSForegroundColorAttributeName:CustomGray,
                                                NSStrikethroughStyleAttributeName:@(NSUnderlinePatternSolid|NSUnderlineStyleSingle)}
                                        range:range];
            }
        }
        //优惠价处理
        if(price && price.length > 0){
            NSRange range = [strSecond rangeOfString:price];
            if(range.location != NSNotFound){
                range.location += 4;
                range.length -= 4;
                [attributedText addAttribute:NSForegroundColorAttributeName
                                       value:CustomPink
                                       range:range];
            }
        }
        //计算尺寸
        size = [attributedText boundingRectWithSize:CGSizeMake(width - x, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil].size;
        _lbSecond.frame = CGRectMake(x - kDefaultInset.right, y, width - kDefaultInset.right, size.height);
        _lbSecond.attributedText = attributedText;
        [self addSubview:_lbSecond];
        y = CGRectGetMaxY(_lbSecond.frame) + kDefaultInset.bottom;
    }
    
    //重置高度
    CGRect frame = self.frame;
    frame.size.height = y;
    self.backgroundColor = RGBA(43, 189, 188, .6);
    self.frame = frame;
}


@end