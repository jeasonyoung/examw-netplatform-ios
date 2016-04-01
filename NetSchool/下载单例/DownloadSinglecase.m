//
//  DownloadSinglecase.m
//  NetSchool
//
//  Created by 周文松 on 15/9/11.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "DownloadSinglecase.h"
#import "CommonHelper.h"

//下载目录
#define kDOWNLOAD_DIR_VIDEO_FILES @"VideoFiles"//下载视频文件根目录
#define kDOWNLOAD_DIR_VIDEO_TEMPS @"VideoTemps"//下载视频临时文件根目录
//下载配置存储后缀
#define kDOWNLOAD_CFG_SUFFIX @".json"
//
#define kDOWNLOAD_TMP_SUFFIX @".tmp"//下载临时文件后缀
/**
 *  成员变量扩展。
 */
@interface DownloadSinglecase(){
    //ASI网络队列。
    ASINetworkQueue *_netWorkQueue;
    //是否恢复。
    BOOL _recovery;
    //视频文件存储根路径/临时文件存储根路径
    NSString *_videoFiles,*_videoTemps;
    //在下载文件列表中的位置。
    NSInteger _num;
}
@end

@implementation DownloadSinglecase
singleton_implementation(DownloadSinglecase)

/**
 *  创建下载根目录。
 */
-(void)createPath{
    DLog(@"创建本地目录...")
    //存储根目录地址
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [paths objectAtIndex:0];
    filePath = [filePath stringByAppendingPathComponent:md5([Infomation readInfo][@"userName"])];
    DLog(@"root=>%@",filePath);
    //视频文件目录
    _videoFiles = [filePath stringByAppendingPathComponent:kDOWNLOAD_DIR_VIDEO_FILES];
    DLog(@"_videoFiles=>%@",_videoFiles);
    //视频临时文件目录
    _videoTemps = [filePath stringByAppendingPathComponent:kDOWNLOAD_DIR_VIDEO_TEMPS];
    DLog(@"_videoTemps=>%@",_videoTemps);
    
    //加载视频临时文件目录
    [self loadTempfiles];
    //加载下载完成目录
    [self loadFinishedfiles];
}

/**
 *  加载下载完成的文件数据。
 */
-(NSArray<NSDictionary *> *)loadFinishedfiles{
    //初始化完成文件列表
    _finishedList = [NSMutableArray array];
    //初始化文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //检查下载完成目录是否存在
    if([fileManager fileExistsAtPath:_videoFiles]){
        NSError *error;
        //获取目录下所有文件
        NSArray *filelist = [fileManager contentsOfDirectoryAtPath:_videoFiles error:&error];
        if(error){
            DLog(@"加载目录[%@]下文件异常:%@", _videoFiles, error);
            return _finishedList;
        }
        //检查是否有文件
        if(!filelist || filelist.count == 0) return _finishedList;
        //循环下载完成的目录文件
        for(NSString *fileName in filelist){
            //文件名不存在
            if(!fileName || fileName.length == 0) continue;
            //排除.json文件
            if([fileName rangeOfString:kDOWNLOAD_CFG_SUFFIX options:NSBackwardsSearch].location != NSNotFound)
                continue;
            //排除.tmp文件
            if([fileName rangeOfString:kDOWNLOAD_TMP_SUFFIX options:NSBackwardsSearch].location != NSNotFound)
                continue;
            NSString *path = [_videoFiles stringByAppendingPathComponent:fileName];
            //解密文件
            NSArray *array = [self recoverFinishFileName:fileName];
            if(array && array.count > 1){
                DLog(@"缓存文件路径:%@", path);
                //添加到列表
                [_finishedList addObject:@{kDOWNLOAD_CFG_OPT_ID:array[0],
                                           kDOWNLOAD_CFG_OPT_NAME:array[1],
                                           kDOWNLOAD_CFG_OPT_URL:path}];
            }else{//删除不符合规则的下载文件
                [fileManager removeItemAtPath:path error:&error];
                if(error){
                    DLog(@"删除文件[%@]异常:%@",path, error);
                }
            }
        }
        //数据排序
        if(_finishedList && _finishedList.count > 0){
            //DLog(@"_finishedList排序前=>%@", _finishedList);
            
            [_finishedList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                if([obj1 isKindOfClass:[NSDictionary class]] && [obj2 isKindOfClass:[NSDictionary class]]){
                    NSString *name1 = ((NSDictionary *)obj1)[kDOWNLOAD_CFG_OPT_NAME];
                    NSString *name2 = ((NSDictionary *)obj2)[kDOWNLOAD_CFG_OPT_NAME];
                    
                    return [name1 integerValue] < [name2 integerValue] ? NSOrderedAscending : NSOrderedDescending;
                }
                return NSOrderedAscending;
            }];
            
            //DLog(@"_finishedList排序后=>%@", _finishedList);
        }
    }
    //返回
    return _finishedList;
}

/**
 *  加载视频临时文件目录
 */
- (void)loadTempfiles{
    //初始化文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //检查临时目录是否存在
    if([fileManager fileExistsAtPath:_videoTemps]){
        NSError *error;
        //获取临时目录下的所有文件
        NSArray *filelist = [fileManager contentsOfDirectoryAtPath:_videoTemps error:&error];
        //读取目录下文件异常
        if(error){
            DLog(@"读取临时目录[%@]下文件异常:%@", _videoTemps, error);
            return;
        }
        //不存在临时文件
        if(!filelist || filelist.count == 0) return;
        //临时数据配置数组
        NSMutableArray *tempFileConfigs = [NSMutableArray array];
        //循环目录下文件名
        for (NSString *file in filelist){
            //以.json结尾的文件是下载文件的配置文件，存在文件名称，文件总大小，文件下载URL
            if([file rangeOfString:kDOWNLOAD_CFG_SUFFIX].location == NSNotFound) continue;
            //读取临时文件配置内容
            NSDictionary *cfg = [self loadCfgDataWithFileName:file];
            if(cfg && cfg.count > 0){
                //添加到配置数组
                [tempFileConfigs addObject:cfg];
            }
        }
        //是否存在临时文件配置
        if(tempFileConfigs.count > 0) {
            [self beginRequest:tempFileConfigs isBeginDown:NO];
        }
    }
}

/**
 *  下载数据分类。
 *
 *  @param datas 下载数据。
 *
 *  @return 排序结果。
 */
-(NSArray<NSArray *> *)sortWithDowningDatas:(NSArray *)datas{
    DLog(@"下载数据分类....");
    //初始化
    NSMutableArray *downloads = [NSMutableArray array];
    //初始化文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    //检查已下载目录是否存在
    if([fileManager fileExistsAtPath:_videoFiles]){
        //已下载的视频文件名集合。
        NSArray *videoFiles = [fileManager contentsOfDirectoryAtPath:_videoFiles error:&error];
        if(error){
            DLog(@"加载已下载目录[%@]的视频文件名失败:%@", _videoFiles, error);
        }
        //已下载完成
        if(videoFiles && videoFiles.count > 0){
            for(NSDictionary *dict in datas){
                NSString *filename = [self createFinishFileName:dict];
                if([videoFiles containsObject:filename]){
                    [downloads addObject:dict];
                }
            }
        }
    }
    //检查正在下载的
    if([fileManager fileExistsAtPath:_videoTemps]){
        //加载正在下载的配置文件。
        NSArray *tmpFiles = [fileManager contentsOfDirectoryAtPath:_videoTemps error:&error];
        if(error){
            DLog(@"加载下载临时目录[%@]的文件名失败:%@", _videoTemps, error);
        }
        //加载临时文件列表
        if(tmpFiles && tmpFiles.count > 0){
            for(NSDictionary *dict in datas){
                NSString *cfgName = [self createCfgFileNameWithDatas:dict];
                if([tmpFiles containsObject:cfgName]){
                    [downloads addObject:dict];
                }
            }
        }
    }
    //未下载完成
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", downloads];
    NSArray *undownloads = [datas filteredArrayUsingPredicate:filterPredicate];
    //
    return @[undownloads,downloads];
}


/**
 *  加载配置数据。
 *
 *  @param path 配置文件路径。
 *
 *  @return 配置数据。
 */
-(NSDictionary *)loadCfgDataWithFileName:(NSString *)fileName{
    if(!fileName || fileName.length == 0) return nil;
    //配置文件路径
    NSString *path = [_videoTemps stringByAppendingPathComponent:fileName];
    DLog(@"加载配置文件:%@", path);
    if(path && path.length > 0){
        NSError *error;
        //读取文件内容
        NSString *json = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
        if(error){
            DLog(@"读取文件[%@]失败:%@", path, error);
            return nil;
        }
        //解析json
        DLog(@"file(%@)=>%@",path,json);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:kNilOptions
                                                               error:&error];
        if(error){
            DLog(@"解析JSON失败:%@",error);
            return nil;
        }
        //加载配置结果
        return @{kDOWNLOAD_CFG_OPT_ID : dict[kDOWNLOAD_CFG_OPT_ID],
                 kDOWNLOAD_CFG_OPT_NAME : dict[kDOWNLOAD_CFG_OPT_NAME],
                 kDOWNLOAD_CFG_OPT_SIZE : (dict[kDOWNLOAD_CFG_OPT_SIZE] ?: @""),
                 kDOWNLOAD_CFG_OPT_URL : dict[kDOWNLOAD_CFG_OPT_URL] ?: @""};
    }
    return nil;
}

/**
 *  创建配置文件。
 *
 *  @param datas 配置内容。
 *  @param path  配置文件路径。
 */
-(void)createCfgFileWithDatas:(NSDictionary *)datas{
    DLog(@"创建配置文件...");
    if(!datas || datas.count == 0) return;
    NSError *error;
    //生成下载配置json文件
    NSDictionary *cfg = @{kDOWNLOAD_CFG_OPT_ID : datas[kDOWNLOAD_CFG_OPT_ID],
                          kDOWNLOAD_CFG_OPT_NAME : datas[kDOWNLOAD_CFG_OPT_NAME],
                          kDOWNLOAD_CFG_OPT_SIZE : (datas[kDOWNLOAD_CFG_OPT_SIZE] ?: @""),
                          kDOWNLOAD_CFG_OPT_URL : datas[kDOWNLOAD_CFG_OPT_URL]};
    //对象转换为JSON数据
    NSData *cfg_data = [NSJSONSerialization dataWithJSONObject:cfg
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if(error){
        DLog(@"JSON序列化失败[%@]:%@", error, cfg);
        return;
    }
    //转换为JSON字符串
    NSString *cfgJson = [[NSString alloc] initWithData:cfg_data
                                              encoding:NSUTF8StringEncoding];
    DLog(@"下载文件配置JSON:%@", cfgJson);
    //生成JSON文件存储在临时目录
    NSString *cfgFileName = [self createCfgFileNameWithDatas:datas];
    [cfgJson writeToFile:[_videoTemps stringByAppendingPathComponent:cfgFileName]
              atomically:YES
                encoding:NSUTF8StringEncoding
                   error:&error];
    if(error){
        DLog(@"生成配置文件[%@]失败:%@", cfgFileName, error);
    }
}

/**
 *  创建配置文件名称。
 *
 *  @param datas 下载文件信息。
 *
 *  @return 配置文件名称。
 */
-(NSString *)createCfgFileNameWithDatas:(NSDictionary *)datas{
    if(datas && datas[kDOWNLOAD_CFG_OPT_ID]){
        NSString *cfgFileName = [datas[kDOWNLOAD_CFG_OPT_ID] stringByAppendingString:kDOWNLOAD_CFG_SUFFIX];
        DLog(@"创建配置文件名:%@", cfgFileName);
        return cfgFileName;
    }
    return nil;
}

/**
 *  删除配置文件。
 *
 *  @param datas 配置数据信息
 */
-(void)deleteCfgFileWithDatas:(NSDictionary *)datas{
    if(!datas || datas.count == 0)return;
    //配置文件名称
    NSString *cfgFileName = [datas[kDOWNLOAD_CFG_OPT_ID] stringByAppendingString:kDOWNLOAD_CFG_SUFFIX];
    DLog(@"del=>%@", cfgFileName);
    NSString *path = [_videoTemps stringByAppendingPathComponent:cfgFileName];
    DLog(@"del path=>%@", path);
    //初始化文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){//如果存在临时文件的配置文件,则删除
        NSError *error;
        [fileManager removeItemAtPath:path error:&error];
        if(error){
            DLog(@"删除配置文件[%@]失败:%@", cfgFileName, error);
        }
    }
}

/**
 *  创建下载临时文件路径。
 *
 *  @param datas 下载文件信息。
 *
 *  @return 下载临时文件路径。
 */
-(NSString *)createTempFilePathWithDatas:(NSDictionary *)datas{
    if(!datas || datas.count == 0)return nil;
    //临时下载文件
    NSString *tmpFileName = [datas[kDOWNLOAD_CFG_OPT_ID] stringByAppendingString:kDOWNLOAD_TMP_SUFFIX];
    DLog(@"下载临时文件名:%@", tmpFileName);
    NSString *tmpFilePath = [_videoTemps stringByAppendingPathComponent:tmpFileName];
    DLog(@"下载临时文件路径=>%@", tmpFilePath);
    return tmpFilePath;
}

/**
 *  删除临时文件。
 *
 *  @param datas 下载文件临时文件。
 */
-(void)deleteTempFileWithDatas:(NSDictionary *)datas{
    if(!datas || datas.count == 0)return;
    //临时下载文件
    NSString *tmpFileName = [datas[kDOWNLOAD_CFG_OPT_ID] stringByAppendingString:kDOWNLOAD_TMP_SUFFIX];
    DLog(@"下载临时文件名:%@", tmpFileName);
    NSString *tmpFilePath = [_videoTemps stringByAppendingPathComponent:tmpFileName];
    //初始化文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:tmpFilePath]){
        NSError *error;
        [fileManager removeItemAtPath:tmpFilePath error:&error];
        if(error){
            DLog(@"删除下载临时文件[%@]失败:%@", tmpFilePath, error);
        }
    }
}

/**
 *  创建下载完成后的文件名
 *
 *  @param datas 配置数据。
 *
 *  @return 文件名(hex)
 */
-(NSString *)createFinishFileName:(NSDictionary *)datas{
    if(datas && datas.count > 0){
        NSString *hex = [CommonHelper toHexWithArray:@[datas[kDOWNLOAD_CFG_OPT_ID],
                                                       datas[kDOWNLOAD_CFG_OPT_NAME]]];
        DLog(@"生成存储文件名称=>%@", hex);
        return hex;
    }
    return nil;
}

/**
 *  还原下载文件名数据。
 *
 *  @param hex 原文件名
 *
 *  @return 恢复数据
 */
-(NSArray *)recoverFinishFileName:(NSString *)hex{
    if(!hex || hex.length == 0)return nil;
    NSArray *result = nil;
    @try {
        //解密
        result = [CommonHelper fromHex:hex];
        if(result && result.count > 0){
            DLog(@"存储文件解密结果=>%@", [result componentsJoinedByString:@","]);
        }
    }
    @catch (NSException *e) {
        DLog(@"hex解密异常:[%@]=>%@", hex, e);
    }
    @finally{
        return result;
    }
}


/**
 *  开始请求下载。
 *
 *  @param dataArray   下载文件配置集合。
 *  @param isBeginDown 是否开始下载。
 */
-(void)beginRequest:(NSArray<NSDictionary *> *)dataArray isBeginDown:(BOOL)isBeginDown{
    DLog(@"开始请求下载...");
    //初始化网络队列
    if (!_netWorkQueue) {
        DLog(@"初始化网络队列...");
        _netWorkQueue  = [[ASINetworkQueue alloc] init];
        [_netWorkQueue reset];
        [_netWorkQueue setShowAccurateProgress:YES];
        [_netWorkQueue setShouldCancelAllRequestsOnFailure:NO];
        [_netWorkQueue cancelAllOperations];
        _downingList = [NSMutableArray array];
        [_netWorkQueue go];
        _netWorkQueue.maxConcurrentOperationCount = 2;
    }
    NSError *error;
    //初始化文件管理器
    NSFileManager *fileManager=[NSFileManager defaultManager];
    //检查目录是否存在
    if(![fileManager fileExistsAtPath:_videoFiles]){//视频目录不存在
        //创建视频缓存目录
        [fileManager createDirectoryAtPath:_videoFiles
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        //创建目录失败
        if(error){
            DLog(@"创建视频缓存目录[%@]失败:%@",_videoFiles, error);
            return;
        }
    }
    //检查临时目录是否存在
    if(![fileManager fileExistsAtPath:_videoTemps]){//临时目录不存在
        //创建临时目录不存在
        [fileManager createDirectoryAtPath:_videoTemps
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        //创建目录失败
        if(error){
            DLog(@"创建视频缓存临时目录[%@]失败:%@",_videoTemps, error);
            return;
        }
    }
    //循环下载配置信息
    for(NSDictionary *datas in dataArray){
        //
        NSString *url = datas[kDOWNLOAD_CFG_OPT_URL];
        if([url isKindOfClass:[NSNull class]] || !url || url.length == 0){
            url = datas[@"highVideoUrl"];
            if([url isKindOfClass:[NSNull class]] || !url || url.length == 0){
                url = datas[@"superVideoVrl"];
                if([url isKindOfClass:[NSNull class]] || !url || url.length == 0){
                    DLog(@"视频URL不存在!");
                    continue;
                }
            }
        }
        //视频Url
        //NSURL *mUrl = [NSURL URLWithString:datas[kDOWNLOAD_CFG_OPT_URL]];
        //初始化数据字典
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:datas];
        //设置视频地址
        data[kDOWNLOAD_CFG_OPT_URL] = url;
        //生成下载配置文件
        [self createCfgFileWithDatas:data];
        //是否第一次
        data[kDOWNLOAD_CFG_IsFrist] = [NSNumber numberWithBool:YES];
        //临时下载文件
        NSString *tmpFilePath = [self createTempFilePathWithDatas:data];
        //获取临时文件大小
        NSData *fileData= [fileManager contentsAtPath:tmpFilePath];
        NSInteger receivedDataLength = [fileData length];
        data[kDOWNLOAD_CFG_FileReceivedSize] = [NSString stringWithFormat:@"%i",(int)receivedDataLength];
        //如果文件重复下载或暂停、继续，则把队列中的请求删除，重新添加
        for(ASIHTTPRequest *tempRequest in _downingList){
            NSDictionary *tDic = tempRequest.userInfo[kDOWNLOAD_REQ_U_FILE];
            if ([tDic[kDOWNLOAD_CFG_OPT_ID] isEqualToString:datas[kDOWNLOAD_CFG_OPT_ID]]){
                _num = [_downingList indexOfObject:tempRequest];
                _recovery = YES;
                [_downingList removeObject:tempRequest];
                break;
            }
        }
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.delegate = self;
        request.shouldContinueWhenAppEntersBackground = YES;
        //设置下载文件保存路径
        NSString *downloadFileName = [self createFinishFileName:data];
        [request setDownloadDestinationPath:[_videoFiles stringByAppendingPathComponent:downloadFileName]];
        //设置临时文件保存路径
        [request setTemporaryFileDownloadPath:tmpFilePath];
        //设置下载进度代理;
        [request setDownloadProgressDelegate:self];
        //支持断点续传
        [request setAllowResumeForFileDownloads:YES];
        //设置ASI请求对象
        data[kDOWNLOAD_CFG_Request] = request;
        //开始下载
        if(isBeginDown){
            data[kDOWNLOAD_CFG_IsDownloading] = [NSNumber numberWithBool:NO];
            data[kDOWNLOAD_CFG_IsWaiting] = [NSNumber numberWithBool:YES];
            if(request){
                //添加到ASINetworkQueue队列去下载
                [_netWorkQueue addOperation:request];
            }
        }else{
            data[kDOWNLOAD_CFG_IsDownloading] = [NSNumber numberWithBool:NO];
            data[kDOWNLOAD_CFG_IsWaiting] = [NSNumber numberWithBool:NO];
        }
        //设置上下文的文件基本信息
        request.userInfo = @{kDOWNLOAD_REQ_U_FILE : data};
        [request setTimeOutSeconds:10.0f];
        //
        if (_recovery){/*暂停恢复*/
            [_downingList insertObject:request atIndex:_num];
            _recovery = NO;
        } else{/*新增加的下载 每一个新下载请求都会加载到数组的最后一列 也就是现在列表的最后一行*/
            [_downingList addObject:request];
        }
        //委托处理
        if ([_downloadDelegate respondsToSelector:@selector(waiting:)] &&
            [_downloadDelegate conformsToProtocol:@protocol(DownloadDelegate)]){
            dispatch_async( dispatch_get_main_queue(),^{
                [_downloadDelegate waiting:request];
            });
        }
    }
    //其实刷新是需要考虑 新增加的下载，暂停恢复 不需要 刷新。这里是方便。
    NSNotificationPost(RefreshWithViews, nil, nil);
}

/**
 *  取消下载。
 *
 *  @param request ASI请求对象。
 */
-(void)cancelDownload:(ASIHTTPRequest *)request{
    DLog(@"取消文件下载...");
    if(!request)return;
    //获取上下文信息
    NSDictionary *fileInfo = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    if(!fileInfo || fileInfo.count == 0) return;
    //删除配置文件
    [self deleteCfgFileWithDatas:fileInfo];
    //删除下载临时文件
    [self deleteTempFileWithDatas:fileInfo];
    //从下载文件队列中移除
    if(_downingList && _downingList.count > 0){
        [_downingList removeObject:request];
    }
    //取下下载ASI请求
    [request cancel];
    //销毁对象
    request = nil;
}

/**
 *  删除已下载的文件。
 *
 *  @param datas 文件数据。
 */
-(void)deleteDownloadWithDatas:(NSDictionary *)datas{
    if(!datas || datas.count == 0) return;
    NSString *path = datas[kDOWNLOAD_CFG_OPT_URL];
    if(!path || path.length == 0) return;
    DLog(@"删除视频文件=>%@",path);
    //初始化文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){//如果文件存在则删除
        NSError *error;
        [fileManager removeItemAtPath:path error:&error];
        if(error){
            DLog(@"删除文件[%@]异常:%@", path, error);
        }
    }
    //移除出已下载文件列表
    if(_finishedList && _finishedList.count > 0){
        [_finishedList removeObject:datas];
    }
}

/**
 *  加载下载文件路径.
 *
 *  @param datas 文件信息。
 *
 *  @return 本地文件路径。
 */
-(NSString *)loadDownloadFilePathWithDatas:(NSDictionary *)datas{
    if(datas && datas.count > 0 && _videoFiles){
        if(!datas[kDOWNLOAD_CFG_OPT_ID] || !datas[kDOWNLOAD_CFG_OPT_NAME]) return nil;
        //下载文件名
        NSString *fileName = [self createFinishFileName:datas];
        //下载文件路径
        NSString *path = [_videoFiles stringByAppendingPathComponent:fileName];
        DLog(@"下载文件路径=>%@", path);
        //初始化文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:path]){
            return path;
        }
        DLog(@"文件不存在=>%@", path);
    }
    return nil;
}

#pragma mark -ASIHTTPRequestDelegate
/**
 *  请求下载处理。
 *
 *  @param request ASI请求对象
 */
-(void)requestStarted:(ASIHTTPRequest *)request{
    DLog(@"requestStarted...");
    NSMutableDictionary *datas = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    if(!datas || datas.count == 0) return;
    //是否开始下载状态
    datas[kDOWNLOAD_CFG_IsDownloading] = [NSNumber numberWithBool:YES];
    //是否等待状态
    datas[kDOWNLOAD_CFG_IsWaiting] = [NSNumber numberWithBool:NO];
    //委托处理
    if ([_downloadDelegate respondsToSelector:@selector(start:)]
        && [_downloadDelegate conformsToProtocol:@protocol(DownloadDelegate)]){
        dispatch_async( dispatch_get_main_queue(),^{
            [_downloadDelegate start:request];
        });
    }
}
/**
 *  请求接收处理头数据处理
 *
 *  @param request         ASI请求数据
 *  @param responseHeaders 返回头数据
 */
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    DLog(@"request-didReceiveResponseHeaders...");
    //获取上下文数据
    NSMutableDictionary *fileInfo = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    //
    //NSString *contentLengthStr = [[request responseHeaders] objectForKey:@"Content-Length"];
    float contentSize = [CommonHelper getFileSizeNumber:responseHeaders[@"Content-Length"]];
    DLog(@"Content-Length=>%f", contentSize);
    fileInfo[kDOWNLOAD_CFG_OPT_SIZE] = [NSString stringWithFormat:@"%f",[fileInfo[kDOWNLOAD_CFG_FileReceivedSize] floatValue] + contentSize];
    //保存配置
    [self createCfgFileWithDatas:fileInfo];
}
/**
 *  下载完成处理。
 *  将正在下载的文件请求ASIHttpRequest从队列里移除，
 *  并将其配置文件删除掉,然后向已下载列表里添加该文件对象.
 *  @param request ASI请求对象
 */
-(void)requestFinished:(ASIHTTPRequest *)request{
    DLog(@"requestFinished...");
    //获取上下文请求数据
    NSMutableDictionary *fileInfo = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    fileInfo[kDOWNLOAD_CFG_IsDownloading] = [NSNumber numberWithBool:NO];
    fileInfo[kDOWNLOAD_CFG_IsWaiting] = [NSNumber numberWithBool:NO];
    //删除配置文件
    [self deleteCfgFileWithDatas:fileInfo];
    //移除下载中队列
    if(_downingList.count){
        [_downingList removeObject:request];
    }
    //重新加载下载完成文件
    [self loadFinishedfiles];
    //委托处理
    if([_downloadDelegate respondsToSelector:@selector(finishedDownload:)]
       && [_downloadDelegate conformsToProtocol:@protocol(DownloadDelegate)] && _downloadDelegate){
        dispatch_async( dispatch_get_main_queue(),^{
            [self.downloadDelegate finishedDownload:request];
        });
    }
    //
    NSNotificationPost(RefreshWithViews, nil, nil);
}
/**
 *  请求失败处理。
 *
 *  @param request ASI请求对象。
 */
-(void)requestFailed:(ASIHTTPRequest *)request{
    DLog(@"requestFailed...");
    NSMutableDictionary *datas = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    //是否开始下载状态
    datas[kDOWNLOAD_CFG_IsDownloading] = [NSNumber numberWithBool:NO];
    //是否等待状态
    datas[kDOWNLOAD_CFG_IsWaiting] = [NSNumber numberWithBool:NO];
    //下载队列处理
    if(_netWorkQueue.maxConcurrentOperationCount == 0){
        _netWorkQueue = nil;
    }
    //委托处理
    if ([_downloadDelegate respondsToSelector:@selector(failedDownload:)]
        && [_downloadDelegate conformsToProtocol:@protocol(DownloadDelegate)]){
        dispatch_async( dispatch_get_main_queue(),^{
            [_downloadDelegate failedDownload:request];
        });
    }
}

#pragma mark -ASIProgressDelegate
/**
 *  请求接收数据处理。
 *
 *  @param request ASI请求对象。
 *  @param bytes   接收到的数据。
 */
-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes{
    DLog(@"bytes:%lld",bytes)
    //获取上下文信息
    NSMutableDictionary *fileInfo = request.userInfo[kDOWNLOAD_REQ_U_FILE];
    //接收数据处理
    if(![fileInfo[kDOWNLOAD_CFG_IsFrist] boolValue]){//原因 首次进来 他会把总大小加在一起
        long long total = [fileInfo[kDOWNLOAD_CFG_FileReceivedSize] longLongValue] + bytes;
        DLog("totals:%lld", total);
        fileInfo[kDOWNLOAD_CFG_FileReceivedSize]= [NSString stringWithFormat:@"%lld", total];
    }
    fileInfo[kDOWNLOAD_CFG_IsFrist] = [NSNumber numberWithBool:NO];
    //下载进度处理
    if([_downloadDelegate respondsToSelector:@selector(updateCellProgress:)]
        && [_downloadDelegate conformsToProtocol:@protocol(DownloadDelegate)]){
        dispatch_async( dispatch_get_main_queue(),^{
            [self.downloadDelegate updateCellProgress:request];
        });
    }
}


@end
