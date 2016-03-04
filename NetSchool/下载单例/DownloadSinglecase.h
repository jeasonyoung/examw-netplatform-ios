//
//  DownloadSinglecase.h
//  NetSchool
//
//  Created by 周文松 on 15/9/11.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//
/**
 *  下载单列修改
 *  modify by yangyong on 16/03/04
 */

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

//下载配置项
#define kDOWNLOAD_CFG_OPT_ID @"id"//下载文件ID
#define kDOWNLOAD_CFG_OPT_NAME @"name"//下载文件名称
#define kDOWNLOAD_CFG_OPT_SIZE @"fileSize"//下载文件大小
#define kDOWNLOAD_CFG_OPT_URL @"videoUrl"//下载文件URL
//配置扩展
#define kDOWNLOAD_CFG_IsFrist @"isFristReceived"//是否第一次接收数据
#define kDOWNLOAD_CFG_FileReceivedSize @"fileReceivedSize"//下载的文件大小
#define kDOWNLOAD_CFG_Request @"request"//ASI请求对象
#define kDOWNLOAD_CFG_IsDownloading @"isDownloading"//下载中
#define kDOWNLOAD_CFG_IsWaiting @"isWaiting"//下载等待
//
#define kDOWNLOAD_REQ_U_FILE @"File"//

/**
 *  下载委托。
 */
@protocol DownloadDelegate <NSObject>
/**
 *  @brief 下载等待。
 *
 *  @param request ASI请求对象
 */
-(void)waiting:(ASIHTTPRequest *)request;
/**
 *  @brief 开始下载。
 *
 *  @param request ASI请求对象
 */
-(void)start:(ASIHTTPRequest *)request;
/**
 *  @brief 下载失败。
 *
 *  @param request ASI请求对象。
 */
-(void)failedDownload:(ASIHTTPRequest *)request;
/**
 *  @brief 更新下载的进度。
 *
 *  @param request ASI请求对象。
 */
-(void)updateCellProgress:(ASIHTTPRequest *)request;
/**
 *  @brief 下载完成。
 *
 *  @param request ASI请求对象。
 */
-(void)finishedDownload:(ASIHTTPRequest *)request;
@end

/**
 *  @brief 下载器单列类。
 */
@interface DownloadSinglecase: NSObject<ASIHTTPRequestDelegate, ASIProgressDelegate>

singleton_interface(DownloadSinglecase)

/**
 * @brief 获取已下载完成文件集合。
 */
@property(nonatomic,strong,readonly) NSMutableArray<NSDictionary *> *finishedList;
/**
 * @brief 获取正在下载文件集合。
 */
@property(nonatomic,strong,readonly) NSMutableArray<ASIHTTPRequest *> *downingList;

/**
 *  @brief 下载委托。
 */
@property(nonatomic, assign) id<DownloadDelegate> downloadDelegate;

/**
 *  @brief 创建下载根目录。
 */
-(void)createPath;

/**
 *  @brief  读取已下载文件。
 */
-(NSArray<NSDictionary *> *)loadFinishedfiles;

/**
 *  @brief 下载分类。
 *
 *  @param datas 下载列表。
 *
 *  @return 分类列表。
 */
-(NSArray<NSArray *> *)sortWithDowningDatas:(NSArray *)datas;

/**
 *  @brief 开始请求。
 *
 *  @param dataArray 下载列表。
 *  @param isBeginDown 是否开始下载。
 */
-(void)beginRequest:(NSArray<NSDictionary *> *)dataArray isBeginDown:(BOOL)isBeginDown;

/**
 *  @brief 取消下载。
 *
 *  @param request ASI请求对象。
 */
-(void)cancelDownload:(ASIHTTPRequest *)request;

/**
 *  @brief 删除已下载的文件。
 *
 *  @param datas 文件数据。
 */
-(void)deleteDownloadWithDatas:(NSDictionary *)datas;

/**
 *  @brief 加载本地文件路径。
 *
 *  @param datas 文件信息。
 *
 *  @return 本地文件路径。
 */
-(NSString *)loadDownloadFilePathWithDatas:(NSDictionary *)datas;
@end
