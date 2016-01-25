//
//  ProductBuyView.h
//  NetSchool
//
//  Created by jeasonyoung on 16/1/19.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import <UIKit/UIKit.h>

//产品购买委托
@protocol ProductBuyDelegate <NSObject>

//购买事件
-(void)buyWithView:(UIView *)view;

@end

//产品购买View
@interface ProductBuyView : UIView

//购买事件委托
@property(nonatomic,weak)id<ProductBuyDelegate> buyDelegate;

@end