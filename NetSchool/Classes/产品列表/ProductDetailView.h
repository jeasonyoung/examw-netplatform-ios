//
//  ProductDetailView.h
//  NetSchool
//
//  Created by jeasonyoung on 16/1/19.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductModel.h"

//产品明细View
@interface ProductDetailView : UIView

//加载数据
-(void)loadData:(ProductModel *)data;

@end