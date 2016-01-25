//
//  ProductDetailViewController.h
//  NetSchool
//
//  Created by jeasonyoung on 16/1/19.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "PJViewController.h"
#import "ProductModel.h"

//产品明细控制器
@interface ProductDetailViewController : PJViewController

//初始化
-(instancetype)initWithData:(ProductModel *)data;

@end