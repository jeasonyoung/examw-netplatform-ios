//
//  ProductListCell.h
//  NetSchool
//
//  Created by jeasonyoung on 16/1/19.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductListCellFrame.h"
//产品列表Cell
@interface ProductListCell : UITableViewCell

//加载CellFrame数据
-(void)loadDataWithCellFrame:(ProductListCellFrame *)cellFrame;

@end