//
//  OnLineList1ViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/9/1.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "OnLineList1ViewController.h"
#import "PJTableViewCell.h"
#import "MyVideo.h"
#import "DownloadSinglecase.h"

@interface Classlist : PJTableViewCell{
    
}
@end

@implementation Classlist

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.imageView.image = [UIImage imageNamed:@"filetype_1.png"];
        self.textLabel.font = NFont(17);
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.numberOfLines = 0;
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"palyico2.png"]];
        self.accessoryView = view;
        
        _title = [UILabel new];
        _title.font = NFont(12);
        _title.textColor = CustomBlue;
        _title.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_title];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + kDefaultInset.left, 0, DeviceW - (CGRectGetMaxX(self.imageView.frame) + 25 + 35 + kDefaultInset.right * 2 ), 55);
    self.accessoryView.frame = CGRectMake(DeviceW - 25 - kDefaultInset.left, (55 - 25) / 2, 25, 25);
    _title.frame = CGRectMake(CGRectGetMinX(self.accessoryView.frame) - 35, 0, 35, 55);
}


- (void)setDatas:(id)datas{
    //文件是否已下载
    NSString *localPath = [[DownloadSinglecase sharedDownloadSinglecase] loadDownloadFilePathWithDatas:datas];
    if (localPath && localPath.length > 0){
        _title.text = @"本地";
        datas[@"videoUrl"] = localPath;
    }else{
        _title.text = @"在线";
    }
    self.textLabel.text = datas[@"name"];
}

@end

#import "VitamioPlayerViewController.h"
#import "PJNavigationBar.h"
#import "PlayNavigationController.h"
#import "DownViewController.h"

@interface OnLineList1ViewController(){
    UIButton *_goDown;
}
@end

@implementation OnLineList1ViewController



- (id)initWithParameters:(id)parameters;
{
    if ((self = [super initWithParameters:parameters])) {
        [self.navigationItem setNewTitle:parameters[@"name"]];
        [self.navigationItem setBackItemWithTarget:self
                                             title:nil
                                            action:@selector(back)
                                             image:@"back.png"];
        //用户信息隐藏离线缓存
       if([Infomation readAllowDownload]){
            _goDown = [self.navigationItem setRightItemWithTarget:self
                                                            title:@"缓存"
                                                           action:@selector(download)
                                                            image:nil];
            _goDown.hidden = YES;
        }
    }
    return self;
}

- (void)back
{
    [self popViewController];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.table.header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self.table.header beginRefreshing];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datas count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    Classlist *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[Classlist alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.datas = _datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VitamioPlayerViewController *play = [[VitamioPlayerViewController alloc] initWithParameters:_datas[indexPath.row]];
    PlayNavigationController *nav = [[PlayNavigationController alloc] initWithRootViewController:play];;
    
    [self presentViewController:nav];
}

- (void)loadNewData
{
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    if (app->_networkStatus == NotReachable)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self loadDatas:[self coreDataQuery]];
        });
        
        return;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"randUserId"] = [Infomation readInfo][@"data"][@"randUserId"];
    params[@"classId"] = _parameters[@"id"];
    [params setPublicDomain];

    _connection = [BaseModel POST:URL(@"api/m/lessons") parameter:params   class:[BaseModel class]
                          success:^(id data)
                   {
                       [self loadDatas:data[@"data"]];
                       if (![self coreDataUpdate:data[@"data"]])
                           [self coreDataSave:data[@"data"]];
                   }
                          failure:^(NSString *msg, NSString *state)
                   {
                       [self.view makeToast:msg];
                       [_table.header endRefreshing];
                   }];
}

- (void)coreDataSave:(id)datas
{
    
    [MyVideo coreDataSave:datas predicateDatas:_parameters];
}

- (NSArray *)coreDataQuery
{
    
    return [MyVideo coreDataQuery:_parameters];
}

- (BOOL)coreDataUpdate:(id)datas;
{
    return [MyVideo coreDataUpdate:datas predicateDatas:_parameters];
}

- (void)loadDatas:(id)datas
{
    if(_goDown)_goDown.hidden = NO;

    NSMutableArray *array = [NSMutableArray array];
    if(![datas isKindOfClass:[NSNull class]]){
        for (NSDictionary *dic in datas){
            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            newDic[@"pid"] = _parameters[@"id"];
            [array addObject:newDic];
        }
        //排序
        [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDictionary *dic1 = (NSDictionary *)obj1;
            NSDictionary *dic2 = (NSDictionary *)obj2;
        
            if(dic1 && dic2){
                return [dic1[@"orderNo"] intValue] > [dic2[@"orderNo"] intValue];
            }
        
            return 0;
        }];
    }
    
    //
    _datas = array;
    [_table.header endRefreshing];
    [self reloadTabData];

}

- (void)refreshWithViews
{
    [self reloadTabData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 去下载
- (void)download{
    [self addNavigationWithPresentViewController:[[DownViewController alloc] initWithParameters:_datas]];
}
@end
