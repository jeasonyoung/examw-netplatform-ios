//
//  ProductDetailViewController.m
//  NetSchool
//
//  Created by jeasonyoung on 16/1/19.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ProductDetailView.h"
#import "ProductBuyView.h"
#import "AppDelegate.h"

#import "VitamioPlayerViewController.h"
#import "PlayNavigationController.h"

#import "ProductBuyViewController.h"

#define _kProductBuyView_height 50//

#define _kProductDetailCell_identifier @"cell_detail_productDetailViewController"//
//免费试听Cell
@interface ProductDetailCell : UITableViewCell//加载数据
-(void)loadData:(NSDictionary *)data;
@end

@implementation ProductDetailCell

#pragma mark - 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.imageView.image = [UIImage imageNamed:@"filetype_1.png"];
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"palyico2.png"]];
        self.textLabel.font = NFont(15);
        self.textLabel.textColor = CustomBlue;
    }
    return self;
}

#pragma mark - 加载数据
-(void)loadData:(NSDictionary *)data{
   self.textLabel.text = data[@"name"];
}

@end

//产品明细成员变量
@interface ProductDetailViewController ()<ProductBuyDelegate,UITableViewDataSource,UITableViewDelegate>{
    ProductModel *_data;
    ProductDetailView *_detailView;
    ProductBuyView *_buyView;
    UITableView *_tableView;
    NSArray *_datas;
}
@end

//产品明细实现
@implementation ProductDetailViewController

#pragma mark - 初始化
-(instancetype)initWithData:(ProductModel *)data{
    if(self = [super init]){
        _data = data;
        //
        [self.navigationItem setNewTitle:_data.productName];
        [self.navigationItem setBackItemWithTarget:self
                                             title:nil
                                            action:@selector(back)
                                             image:@"back.png"];
    }
    return self;
}

#pragma mark - 返回
-(void)back{
    if(_connection){
        [_connection cancel];
        _connection = nil;
    }
    [self popViewController];
}

#pragma mark - 加载数据
- (void)viewDidLoad {
    [super viewDidLoad];
    //产品明细View
    _detailView = [[ProductDetailView alloc] initWithFrame:self.view.frame];
    [_detailView loadData:_data];
    
    //购买按钮View
    CGRect buyViewFrame = CGRectMake(0, DeviceH - _kProductBuyView_height - 65,
                                     DeviceW, _kProductBuyView_height);
    _buyView = [[ProductBuyView alloc] initWithFrame:buyViewFrame];
    _buyView.buyDelegate = self;
    
    //免费试听View
    CGFloat tableViewX = 0,
    tableViewY = CGRectGetMaxY(_detailView.frame),
    tableViewW = CGRectGetWidth(self.view.frame),
    tableViewH = CGRectGetMinY(_buyView.frame) - tableViewY;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(tableViewX, tableViewY,
                                                                 tableViewW, tableViewH)
                                                style:UITableViewStylePlain];
    UILabel *tableViewHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,0,tableViewW,25)];
    tableViewHeader.font = Font(15);
    tableViewHeader.text = @" 免费试听";
    tableViewHeader.textColor = CustomlightPink;
    tableViewHeader.backgroundColor = RGBA(43, 189, 188, .3);
    _tableView.tableHeaderView = tableViewHeader;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    //加载试听数据
    [self requestData];
    //添加到容器
    [self.view addSubview:_detailView];
    [self.view addSubview:_buyView];
    [self.view addSubview:_tableView];
}

#pragma mark 加载产品试听数据
-(void)requestData{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    if(app->_networkStatus == NotReachable){
        [self.view makeToast:@"没有网络!"];
        DLog(@"没有网络!");
        return;
    }
    //参数处理
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"randUserId"] = [Infomation readInfo][@"data"][@"randUserId"];
    params[@"classId"] = _data.productId;
    params[@"free"] = @1;
    [params setPublicDomain];
    //请求数据
    _connection = [BaseModel POST:URL(@"api/m/lessons")
                        parameter:params
                            class:[BaseModel class]
                          success:^(id data) {
                              DLog(@"请求数据成功!");
                              _datas = data[@"data"];
                              [_tableView reloadData];
                          }
                          failure:^(NSString *msg, NSString *status) {
                              DLog(@"请求数据异常:[status:%@]%@",status, msg);
                              [self.view makeToast:msg];
                          }];
}

#pragma mark - tableView dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_datas) return [_datas count];
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:_kProductDetailCell_identifier];
    if(!cell){
        cell = [[ProductDetailCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:_kProductDetailCell_identifier];
    }
    [cell loadData:_datas[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    VitamioPlayerViewController *play = [[VitamioPlayerViewController alloc] initWithParameters:_datas[indexPath.row]];
    play.isUploadRecord = NO;
    PlayNavigationController *nav = [[PlayNavigationController alloc] initWithRootViewController:play];
    [self presentViewController:nav];
}


#pragma mark - 购买按钮事件处理
-(void)buyWithView:(UIView *)view{
    [self pushViewController:[[ProductBuyViewController alloc] initWithData:_data]];
}

#pragma mark - 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end