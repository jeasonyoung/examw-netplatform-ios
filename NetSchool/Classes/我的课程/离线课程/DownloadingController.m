//
//  DownloadingController.m
//  NetSchool
//
//  Created by 周文松 on 15/9/12.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "DownloadingController.h"
#import "DownloadSinglecase.h"
#import "PJTableViewCell.h"
#import "CommonHelper.h"


@interface DownBtn : UIButton{
    
}
@end

@implementation DownBtn
/**
 *  重载布局子视图。
 */
-(void)layoutSubviews {
    [super layoutSubviews];
    
    // Center image
    CGPoint center = self.imageView.center;
    center.x = self.frame.size.width/2;
    center.y = self.imageView.frame.size.height/2;
    self.imageView.center = center;
    
    //Center text
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.imageView.frame.size.height + 2;
    newFrame.size.width = self.frame.size.width;
    
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}
@end

@interface DownloadingCell : PJTableViewCell
@property (nonatomic, strong) DownBtn *status;

@end

@implementation DownloadingCell

/**
 *  重载初始化。
 *
 *  @param style           <#style description#>
 *  @param reuseIdentifier <#reuseIdentifier description#>
 *
 *  @return <#return value description#>
 */
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.textLabel.font = NFont(17);
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.numberOfLines = 0;
        
        _status = [DownBtn buttonWithType:UIButtonTypeCustom];
        _status.titleLabel.font = NFont(12);
        [_status setTitleColor:CustomBlack forState:UIControlStateNormal];
        self.accessoryView = _status;
        
        self.detailTextLabel.font = NFont(14);
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.textColor = CustomBlack;
        
    }
    return self;
}

/**
 *  重载子视图布局。
 */
-(void)layoutSubviews{
    [super layoutSubviews];
    _status.frame = CGRectMake(DeviceW - kDefaultInset.left * 2 - 50, (55 - 50) / 2, 50, 50);
    CGSize titleSize = [NSObject getSizeWithText:self.textLabel.text font:self.textLabel.font maxSize:CGSizeMake(CGRectGetMinX(_status.frame) - kDefaultInset.left * 3, MAXFLOAT)];
    self.textLabel.frame = CGRectMake( kDefaultInset.left * 2, kDefaultInset.top, titleSize.width, titleSize.height);
    self.detailTextLabel.frame = CGRectMake(kDefaultInset.left * 2, CGRectGetMaxY(self.textLabel.frame) + kDefaultInset.top, CGRectGetMinX(_status.frame) - kDefaultInset.left * 3, self.detailTextLabel.font.lineHeight);
}

-(void)setDatas:(id)datas{
    _datas = datas;
    
    self.textLabel.text = datas[kDOWNLOAD_CFG_OPT_NAME];

    BOOL isWaiting = [datas[kDOWNLOAD_CFG_IsWaiting] boolValue];
    BOOL isDownloading = [datas[kDOWNLOAD_CFG_IsDownloading] boolValue];
    
    NSString *fileCurrentSize = [NSString stringWithFormat:@"%.1f",[CommonHelper getFileSizeNumber:datas[kDOWNLOAD_CFG_FileReceivedSize]] / [CommonHelper getFileSizeNumber:datas[kDOWNLOAD_CFG_OPT_SIZE]] * 100];
    if (![fileCurrentSize integerValue]) {
        fileCurrentSize = @"0";
    }
    self.detailTextLabel.text = [NSString stringWithFormat:@"(%@) ----- %@%% ",[NSString stringWithFormat:@"%.1fM/%.1fM",[datas[kDOWNLOAD_CFG_FileReceivedSize] floatValue] / 1024 / 1024,[datas[kDOWNLOAD_CFG_OPT_SIZE] floatValue] / 1024 / 1024],fileCurrentSize ];
    if (isDownloading && !isWaiting)
    {
        [_status setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
        [_status setTitle:@"正在缓存" forState:UIControlStateNormal];
    }
    else if (!isDownloading && isWaiting)
    {
        [_status setTitle:@"等待中" forState:UIControlStateNormal];
        [_status setImage:[UIImage imageNamed:@"waitButton.png"] forState:UIControlStateNormal];
    }
    else if (!isDownloading && !isWaiting)
    {
        [_status setTitle:@"已暂停" forState:UIControlStateNormal];
        [_status setImage:[UIImage imageNamed:@"downloadButtonNomal.png"] forState:UIControlStateNormal];
    }
}

@end

/**
 *  正在下载控制器成员变量。
 */
@interface DownloadingController()<DownloadDelegate>{
    
}
@end

@implementation DownloadingController

-(id)init{
    if ((self = [super init])) {
        self.title = @"缓存中";
    }
    return self;
}


-(void)dealloc{
    [DownloadSinglecase sharedDownloadSinglecase].downloadDelegate = nil;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _table.allowsSelectionDuringEditing = YES;
    [DownloadSinglecase sharedDownloadSinglecase].downloadDelegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refreshWithViews];
}

-(void)refreshWithViews{
    [self reloadTabData];
}

-(BOOL)eventWithEdit:(BOOL)hasEdit{
    if(hasEdit){
        if([DownloadSinglecase sharedDownloadSinglecase].downingList.count){
             [_table setEditing:hasEdit animated:YES];
            return hasEdit;
        }
        return !hasEdit;
    }
    [_table setEditing:hasEdit animated:YES];
    return hasEdit;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [DownloadSinglecase sharedDownloadSinglecase].downingList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ASIHTTPRequest *request = [DownloadSinglecase sharedDownloadSinglecase].downingList[indexPath.row];
    NSMutableDictionary *fileInfo = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    CGSize titleSize = [NSObject getSizeWithText:fileInfo[kDOWNLOAD_CFG_OPT_NAME] font:NFont(17) maxSize:CGSizeMake(DeviceW - kDefaultInset.left - 40 - kDefaultInset.left * 3, MAXFLOAT)];

    return kDefaultInset.top * 3 + titleSize.height + NFont(14).lineHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    DownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[DownloadingCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
        [cell.status addTarget:self
                        action:@selector(eventWithDownload:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    ASIHTTPRequest *request = [DownloadSinglecase sharedDownloadSinglecase].downingList[indexPath.row];
    NSMutableDictionary *fileInfo = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    cell.datas = fileInfo;
    return cell;
}

//启动/暂停
-(void)eventWithDownload:(UIButton *)button{
    DownloadingCell *cell = [self getCell:button];
    if(!cell)return;
    
    BOOL isWaiting = [cell.datas[kDOWNLOAD_CFG_IsWaiting] boolValue];
    BOOL isDownloading = [cell.datas[kDOWNLOAD_CFG_IsDownloading] boolValue];
    
    if(isDownloading || isWaiting){
        ASIHTTPRequest *request = cell.datas[kDOWNLOAD_CFG_Request];
        if(request){
            [request cancel];
            request = nil;
        }
    }else{
        [[DownloadSinglecase sharedDownloadSinglecase] beginRequest:@[cell.datas] isBeginDown:YES];
    }
}
//获取Cell
-(DownloadingCell*)getCell:(UIView *)view{
    for (UIView* next = view; next; next = next.superview){
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[DownloadingCell class]]){
            return (DownloadingCell*)nextResponder;
        }
    }
    return nil;
}

//指定哪一行可以编辑 哪行不能编辑
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//设置 哪一行的编辑按钮 状态 指定编辑样式
-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

//判断点击按钮的样式 来去做添加 或删除
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //获取下载单列对象
    DownloadSinglecase *downloadSingle = [DownloadSinglecase sharedDownloadSinglecase];
    
    ASIHTTPRequest *request = downloadSingle.downingList[indexPath.row];
    if(!request) return;
    //取消下载
    [downloadSingle cancelDownload:request];
    //移除数据项
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


#pragma mark -DownloadSinglecaseDelegate
#pragma mark - 下载等待中
-(void)waiting:(ASIHTTPRequest *)request;{
    NSDictionary *fileInfo = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    if(!fileInfo || fileInfo.count == 0)return;
    for(DownloadingCell *cell in _table.visibleCells){
        if (cell.datas == fileInfo){
            [cell.status setImage:[UIImage imageNamed:@"waitButton.png"] forState:UIControlStateNormal];
            [cell.status setTitle:@"等待中" forState:UIControlStateNormal];
            
            float receivedSize = [CommonHelper getFileSizeNumber:fileInfo[kDOWNLOAD_CFG_FileReceivedSize]],
            fileSize = [CommonHelper getFileSizeNumber:fileInfo[kDOWNLOAD_CFG_OPT_SIZE]];
            
            NSString *fileCurrentSize = [NSString stringWithFormat:@"%.1f",(receivedSize / fileSize) * 100];
            if (![fileCurrentSize integerValue]) {
                fileCurrentSize = @"0";
            }
            NSString *abstracts = [NSString stringWithFormat:@"(%@) ----- %@%% ",[NSString stringWithFormat:@"%.1fM/%.1fM",receivedSize / 1024 / 1024,fileSize / 1024 / 1024], fileCurrentSize ];
            cell.detailTextLabel.text = abstracts;
        }
    }
}

#pragma mark - 下载开始
-(void)start:(ASIHTTPRequest *)request{
    NSDictionary *fileInfo = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    if(!fileInfo || fileInfo.count == 0)return;
    for(DownloadingCell *cell in _table.visibleCells){
        if(cell.datas == fileInfo){
            [cell.status setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
            [cell.status setTitle:@"正在缓存" forState:UIControlStateNormal];
            
            float receivedSize = [CommonHelper getFileSizeNumber:fileInfo[kDOWNLOAD_CFG_FileReceivedSize]],
            fileSize = [CommonHelper getFileSizeNumber:fileInfo[kDOWNLOAD_CFG_OPT_SIZE]];
            
            NSString *fileCurrentSize = [NSString stringWithFormat:@"%.1f",(receivedSize / fileSize) * 100];
            NSString *abstracts = [NSString stringWithFormat:@"(%@) ----- %@%% ",[NSString stringWithFormat:@"%.1fM/%.1fM", receivedSize / 1024 / 1024, fileSize / 1024 / 1024],fileCurrentSize];
            cell.detailTextLabel.text = abstracts;
        }
    }
}

#pragma mark - 下载完成
-(void)failedDownload:(ASIHTTPRequest *)request{
    NSDictionary *fileInfo = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    if(!fileInfo || fileInfo.count == 0)return;
    for (DownloadingCell *cell in _table.visibleCells){
        if (cell.datas == fileInfo){
            [cell.status setImage:[UIImage imageNamed:@"downloadButtonNomal.png"] forState:UIControlStateNormal];
            [cell.status setTitle:@"已暂停" forState:UIControlStateNormal];
            
            float receivedSize = [CommonHelper getFileSizeNumber:fileInfo[kDOWNLOAD_CFG_FileReceivedSize]],
            fileSize = [CommonHelper getFileSizeNumber:fileInfo[kDOWNLOAD_CFG_OPT_SIZE]];
            
            NSString *fileCurrentSize = [NSString stringWithFormat:@"%.1f", (receivedSize / fileSize) * 100];
            NSString *abstracts = [NSString stringWithFormat:@"(%@) ----- %@%% ",[NSString stringWithFormat:@"%.1fM/%.1fM", receivedSize / 1024 / 1024, fileSize / 1024 / 1024],fileCurrentSize ];
            cell.detailTextLabel.text = abstracts;
        }
    }
}

#pragma mark - 更新新下砸进度
-(void)updateCellProgress:(ASIHTTPRequest *)request{
    NSDictionary *fileInfo = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    if(!fileInfo || fileInfo.count == 0)return;
    for(DownloadingCell *cell in _table.visibleCells){
        if(cell.datas == fileInfo){
            float receivedSize = [CommonHelper getFileSizeNumber:fileInfo[kDOWNLOAD_CFG_FileReceivedSize]],
            fileSize = [CommonHelper getFileSizeNumber:fileInfo[kDOWNLOAD_CFG_OPT_SIZE]];
            
            NSString *fileCurrentSize = [NSString stringWithFormat:@"%.1f",(receivedSize / fileSize) * 100];
            NSString *abstracts = [NSString stringWithFormat:@"(%@) ----- %@%% ",[NSString stringWithFormat:@"%.1fM/%.1fM", receivedSize / 1024 / 1024, fileSize / 1024 / 1024],fileCurrentSize ];
            cell.detailTextLabel.text = abstracts;
        }
    }
}

#pragma mark - 下载完成（这里暂时没有用到）
-(void)finishedDownload:(ASIHTTPRequest *)request{
    //重新加载table数据
    [self refreshWithViews];
}


-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
