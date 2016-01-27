//
//  RechargeViewController.m
//  NetSchool
//
//  Created by jeasonyoung on 16/1/21.
//  Copyright © 2016年 TalkWeb. All rights reserved.
//

#import "RechargeViewController.h"
#import "AccessConfig.h"
#import "UIView+CGTool.h"

#import <StoreKit/StoreKit.h>

#define kRechargeCell_height 40//
#define kRechargeViewController_identifier @"cell_recharge_identifier"//

//充值事件处理
@protocol RechargeCellDelegate<NSObject>

@required
//充值处理
-(void)rechargeClickWithRechargeId:(NSString *)rechargeId;

@end

//充值Cell
@interface RechargeCell : UITableViewCell{
    UIButton *_btnRecharge;
    NSString *_rechargeId;
}
//充值委托处理
@property(nonatomic,assign)id<RechargeCellDelegate> rechargeDelegate;
//初始化
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
//加载数据
-(void)loadDataWithRechargeId:(NSString *)rechargeId Price:(NSString *)price;
@end

//充值Cell实现
@implementation RechargeCell

#pragma mark - 初始化
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.font = Font(17);
        self.textLabel.textColor = [UIColor redColor];
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        
        
        _btnRecharge = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnRecharge.titleLabel.font = Font(16);
        
        CGFloat w = 100, h = kRechargeCell_height - kDefaultInset.top - kDefaultInset.bottom;
        _btnRecharge.frame = CGRectMake(kDefaultInset.left, kDefaultInset.top, w, h);
        [_btnRecharge setTitle:@"立即充值" forState:UIControlStateNormal];
        UIColor *btnColor = RGBA(255, 165, 0, 1);
        [_btnRecharge setTitleColor:btnColor forState:UIControlStateSelected];
        _btnRecharge.backgroundColor = btnColor;
        [_btnRecharge getCornerRadius:8 borderColor:btnColor borderWidth:.5 masksToBounds:YES];
        [_btnRecharge addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = _btnRecharge;
    }
    return self;
}

#pragma mark - 按钮点击事件处理
-(void)btnClick{
    if(_rechargeDelegate && [_rechargeDelegate respondsToSelector:@selector(rechargeClickWithRechargeId:)]){
        [_rechargeDelegate rechargeClickWithRechargeId:_rechargeId];
    }
}

#pragma mark - 加载数据
-(void)loadDataWithRechargeId:(NSString *)rechargeId Price:(NSString *)price{
    _rechargeId = rechargeId;
    self.textLabel.text = [NSString stringWithFormat:@"¥ %.2f",[price floatValue]];
}
@end

//成员变量
@interface RechargeViewController ()<RechargeCellDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>{
    BOOL _result;
    NSDecimalNumber *_rechargePrice;
}
@end

//充值控制器实现
@implementation RechargeViewController

#pragma mark - 初始化
-(instancetype)initWithRechargeResult:(RechargeResultBlock)result{
    if(self = [super initWithTableViewStyle:UITableViewStylePlain parameters:nil]){
        _rechargeResult = result;
        _result = NO;
        //标题
        [self.navigationItem setNewTitle:@"充值"];
        [self.navigationItem setBackItemWithTarget:self
                                             title:nil
                                            action:@selector(back)
                                             image:@"back.png"];
    }
    return self;
}
#pragma mark -返回处理
-(void)back{
    if(_connection){
        [_connection cancel];
        _connection = nil;
    }
    if(_rechargeResult){
        _rechargeResult(self,_result);
    }else{
        [self popViewController];
    }
}

#pragma mark - 加载数据
- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.table.header = [MJChiBaoZiHeader headerWithRefreshingTarget:self
                                                    refreshingAction:@selector(loadNewData)];
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.table.header beginRefreshing];
    
    //监听充值结果
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

#pragma mark - 取消监听
-(void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark － 加载数据
-(void)loadNewData{
    DLog(@"加载数据...");
    NSDictionary *recharges = [[AccessConfig shared] recharges];
    NSUInteger count = 0;
    if(recharges && (count = [recharges count]) > 0){
        NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:count];
        NSArray *keys = [recharges allKeys];
        keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSInteger o1 = [obj1 integerValue],o2 = [obj2 integerValue];
            return o1 < o2 ? NSOrderedAscending : NSOrderedDescending;
        }];
        for(NSString *key in keys){
            if(!key || key.length == 0) continue;
            [arrays addObject:@{@"price":key,@"chargeId":[recharges objectForKey:key]}];
        }
        //
        [self loadDatas:arrays];
    }
}
#pragma mark - 加载table数据
-(void)loadDatas:(NSArray *)datas{
    _datas = datas;
    [_table.header endRefreshing];
    [self reloadTabData];
}

#pragma mark - 数据列表
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_datas) return [_datas count];
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kRechargeCell_height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RechargeCell *cell = [tableView dequeueReusableCellWithIdentifier:kRechargeViewController_identifier];
    if(!cell){
        cell = [[RechargeCell alloc] initWithReuseIdentifier:kRechargeViewController_identifier];
        cell.rechargeDelegate = self;
    }
    //加载数据
    NSDictionary *row = _datas[indexPath.row];
    [cell loadDataWithRechargeId:row[@"chargeId"] Price:row[@"price"]];
    return cell;
}

#pragma mark - 充值事件处理
-(void)rechargeClickWithRechargeId:(NSString *)rechargeId{
    if([SKPaymentQueue canMakePayments]){
        [self startRechargeWithRechargeId:rechargeId];
    }else{
        [self makeToast:@"用户禁止充值!"];
    }
}

#pragma mark - 启动充值
-(void)startRechargeWithRechargeId:(NSString *)rechargeId{
    DLog(@"产品ID ：%@", rechargeId);
    [MBProgressHUD showMessag:@"正在充值..." toView:self.view];
    //查询产品ID
    SKProductsRequest *queryRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:@[rechargeId]]];
    queryRequest.delegate = self;
    [queryRequest start];
}

#pragma mark - 充值查询回调
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    DLog(@"查询产品请求成功...");
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSArray * recharges = response.products;
    if(recharges.count == 0){
        _rechargePrice = nil;
        [self.view makeToast:@"暂时无法充值，请联系客服人员!"];
        return;
    }
    SKProduct *sp = recharges[0];
    _rechargePrice = sp.price;
    DLog(@"充值信息:%@",@{@"id":sp.productIdentifier,@"title":sp.localizedTitle,@"desc":sp.localizedDescription,@"price":sp.price});
    SKPayment *payment = [SKPayment paymentWithProduct:sp];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
#pragma mark - 充值查询请求不成功
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if(error){
        [self.view makeToast:error.description];
    }
}

#pragma mark - 充值结果
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        if(!transaction) continue;
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchased:{//交易完成
                DLog(@"交易完成[transactionIdentifier = %@]...", transaction.transactionIdentifier);
                [self completeTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:{//交易失败
                DLog(@"交易失败[transactionIdentifier = %@]...", transaction.transactionIdentifier);
                [self failedTrasaction:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored:{//已经购买过该商品
                DLog(@"已经购买过该商品[transactionIdentifier = %@]...", transaction.transactionIdentifier);
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStatePurchasing:{//商品添加进列表
                DLog(@"商品添加进列表[productIdentifier = %@]...", transaction.payment.productIdentifier);
                break;
            }
            default:break;
        }
    }
}

#pragma mark - 完成交易事务
-(void)completeTransaction:(SKPaymentTransaction *)transaction{
    //验证购买凭证
    [self verifyPruchaseWithRechargeId:transaction.payment.productIdentifier
                                Price:_rechargePrice];
    //
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - 验证购买凭据
-(void)verifyPruchaseWithRechargeId:(NSString *)rechargeId Price:(NSDecimalNumber *)price{
    if(!rechargeId || rechargeId.length == 0){
        [self.view makeToast:@"验证充值失败!(获取充值ID失败,请联系客服)"];
        return;
    }
    if(!price || price <= 0){
        [self.view makeToast:@"验证充值失败!(获取充值金额失败,请联系客服)"];
        return;
    }
    //获取验证凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    if(!receiptData || receiptData.length == 0){
        [self.view makeToast:@"验证充值失败!(获取充值凭证失败,请联系客服)"];
        return;
    }
    //凭证转换为hex
    NSString *receiptHex = [self hexFromData:receiptData]; 
    DLog(@"充值凭证:%@",receiptHex);
    //
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"randUserId"] = [Infomation readInfo][@"data"][@"randUserId"];
    params[@"chargeId"] = rechargeId;
    params[@"price"] = price;
    params[@"receipt"] = receiptHex;
    params[@"terminal"] = @kTerminal_no;
    [params setPublicDomain];
    //提交数据
    [MBProgressHUD showMessag:@"正在验证充值..." toView:self.view];
    _connection = [BaseModel POST:URL(@"api/m/verifycharge")
                        parameter:params
                            class:[BaseModel class]
                          success:^(id data) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              _rechargeResult(self,YES);
                          }
                          failure:^(NSString *msg, NSString *status) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"验证充值失败"
                                                                                  message:msg
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"确定"
                                                                        otherButtonTitles:nil, nil];
                              [alterView show];
                              _rechargeResult(self,NO);
                          }];
}

#pragma mark - 交易失败
-(void)failedTrasaction:(SKPaymentTransaction *)transaction{
    if(transaction.error.code == SKErrorPaymentCancelled){
        DLog(@"用户取消交易[transactionIdentifier = %@]...", transaction.transactionIdentifier);
        [self.view makeToast:@"用户取消充值!"];
    }else{
        NSError *err = transaction.error;
        NSString *msg = err.localizedDescription;
        DLog(@"充值失败:%@(%i)", msg, (int)err.code);
        [self.view makeToast:[NSString stringWithFormat:@"充值失败[%@](%i)，请稍后重新尝试!",
                              msg,(int)err.code]];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - 将byte转换为hex
-(NSString *)hexFromData:(NSData *)data{
    if(!data) return nil;
    NSMutableString *hex = [NSMutableString string];
    char *chars = (char *)data.bytes;
    for(NSUInteger i = 0; i < data.length; i++){
        [hex appendFormat:@"%0.2hhx",chars[i]];
    }
    return hex;
}


#pragma mark - 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
