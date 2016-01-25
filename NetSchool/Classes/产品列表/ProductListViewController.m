//
//  ProductListViewController.m
//  NetSchool
//
//  Created by jeasonyoung on 16/1/18.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "ProductListViewController.h"
#import "AppDelegate.h"
#import "ProductListCellFrame.h"
#import "ProductListCell.h"

#import "ProductDetailViewController.h"

#define _kProductListCell_reuseIdentifier @"cell_productListViewController_identifier"//
//成员变量
@interface ProductListViewController (){
    //考试产品字典。
    NSMutableDictionary *_examProductsDict;
}
@end

//类实现
@implementation ProductListViewController

#pragma mark - 重载初始化
-(instancetype)init{
    if(self = [super init]){
        [self.navigationItem setNewTitle:@"课程类目"];
        [self.navigationItem setBackItemWithTarget:self
                                             title:nil
                                            action:@selector(back)
                                             image:@"back.png"];
        
        //初始化考试产品字典
        _examProductsDict = [NSMutableDictionary dictionary];
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
    self.table.header = [MJChiBaoZiHeader headerWithRefreshingTarget:self
                                                    refreshingAction:@selector(loadNewData)];
    [self.table.header beginRefreshing];
}

#pragma mark － 加载数据
-(void)loadNewData{
    [self requestExams];
}

#pragma mark - 请求服务器考试数据
-(void)requestExams{
    DLog(@"请求考试数据...");
    [self requestDataWithServlet:@"api/m/exams" parameters:@{} result:^(id data) {
        if([data isKindOfClass:[NSArray class]]){
            [self loadDatas:(NSArray *)data];
        }else{
            DLog(@"考试返回数据不是数组类型!");
            [self loadDatas:nil];
        }
    }];
}

#pragma mark - 请求服务器产品数据
-(void)requestProductsWithSection:(NSInteger)section{
    DLog(@"请求产品数据...");
    if(_datas && [_datas count]>= section){
        //考试数据
        NSDictionary *examDict = _datas[section];
        if(!examDict || [examDict count] == 0) return;
        //加载考试下产品
        [self requestDataWithServlet:@"api/m/products" parameters:@{@"examId":examDict[@"id"]} result:^(id data) {
            DLog(@"请求产品数据成功!");
            NSArray *arrays = (NSArray *)data;
            if(arrays && [arrays count] > 0){
                NSMutableArray *productCellFrames = [NSMutableArray arrayWithCapacity:[arrays count]];
                //循环
                for(NSDictionary *dict in arrays){
                    if(!dict || [dict count] == 0) continue;
                    ProductModel * model = [[ProductModel alloc] initWithData:dict];
                    if(!model) continue;
                    [productCellFrames addObject:[[ProductListCellFrame alloc] initWithData:model]];
                }
                //
                [_examProductsDict setObject:productCellFrames forKey:[NSNumber numberWithInteger:section]];
                //重新加载数据
                [self.table reloadData];
            }else{
                [_examProductsDict setObject:@[] forKey:[NSNumber numberWithInteger:section]];
            }
        }];
    }
}

#pragma mark -
-(void)requestDataWithServlet:(NSString *)servlet parameters:(NSDictionary *)parameters result:(void(^)(id data))result{
    DLog(@"GET:%@,parameters:%@",servlet, [parameters description]);
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    if(app->_networkStatus == NotReachable){
        [self.view makeToast:@"没有网络!"];
        DLog(@"没有网络!");
        if(result)result(nil);
        return;
    }
    //参数处理
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [params setPublicDomain];
    //请求数据
    _connection = [BaseModel POST:URL(servlet)
                        parameter:params
                            class:[BaseModel class]
                          success:^(id data) {
                              DLog(@"请求数据成功!");
                              if(result)result(data[@"data"]);
                          }
                          failure:^(NSString *msg, NSString *status) {
                              DLog(@"请求数据异常:[status:%@]%@",status, msg);
                              [self.view makeToast:msg];
                              [_table.header endRefreshing];
                          }];
}

#pragma mark - 加载table数据
-(void)loadDatas:(NSArray *)datas{
    _datas = datas;
    [_table.header endRefreshing];
    [self reloadTabData];
}


//table
#pragma mark - 考试分组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_datas count];
}

#pragma mark - 分组高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0f;
}

#pragma mark - 分组名称
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *header = [UILabel new];
    header.font = NFont(15);
    header.textColor = CustomBlack;
    header.backgroundColor = RGBA(43, 189, 188, .6);
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:_datas[section][@"name"]];
    NSMutableParagraphStyle * style = [NSMutableParagraphStyle new];
    style.firstLineHeadIndent = kDefaultInset.left * 2;
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    header.attributedText = attrString;
    return header;
}

#pragma mark - 产品数据
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *products = [_examProductsDict objectForKey:[NSNumber numberWithInteger:section]];
    if(!products || [products count] == 0){
        [self requestProductsWithSection:section];
        return 0;
    }
    return [products count];
}


#pragma mark - 产品数据高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //DLog(@"加载产品高度[%i,%i]...",(int)indexPath.section,(int)indexPath.row);
    NSArray *products = [_examProductsDict objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    if(products && [products count] > indexPath.row){
        ProductListCellFrame *cellFrame = products[indexPath.row];
        if(cellFrame){
            return [cellFrame rowHeight];
        }
    }
    return 0.0f;
}

#pragma mark - 产品数据试图
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:_kProductListCell_reuseIdentifier];
    if(!cell){
        cell = [[ProductListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:_kProductListCell_reuseIdentifier];
        cell.accessoryType = UITableViewCellStyleDefault;
    }
    //加载数据
    NSArray *products = [_examProductsDict objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    if(products && [products count] > indexPath.row){
        ProductListCellFrame *cellFrame = products[indexPath.row];
        if(cellFrame){
            [cell loadDataWithCellFrame:cellFrame];
        }
    }
    return cell;
}

#pragma mark - 选中产品
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //DLog(@"选中产品:[%i,%i]...", indexPath.section,indexPath.row);
    NSArray *products = [_examProductsDict objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    if(products && [products count] > indexPath.row){
        ProductListCellFrame *cellFrame = products[indexPath.row];
        if(cellFrame && cellFrame.model){
            [self pushViewController:[[ProductDetailViewController alloc] initWithData:cellFrame.model]];
        }
    }
}

#pragma mark - 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
