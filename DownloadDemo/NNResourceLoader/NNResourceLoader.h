//
//  NNResourceLoader.h
//   
//
//  Created by liweizhao on 2018/9/13.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NNReasourceHeader.h"
@class NNResourceRequest;

/**
 resource - web、local
 */

// 下载这个操作与要下载的这个文件类型是无关的
// 断点下载

/// 下载中枢
@interface NNResourceLoader : NSObject



// -> url -> 检查本地情况
//                    -> 完整文件     ->callback
//                    -> 不完整文件    ->断点下载
//                    -> 未下载过     ->开始下载
// 后台下载 - ✖️
// ✔️
// MD5 找到对应文件的缓存信息
// 定期清理缓存信息
// 优先度提升
// 下载的任务量的最大并发量

@property (nonatomic, strong) void ((^curDownloadCount)(void));

/// 最大下载量       default : 0 （不限）
- (void)configMaximumLoad:(NSUInteger)maximumLoad;

/// 缓存目录(中断数据、完整数据均在此目录)
+ (NSString *)cacheDirectory;

/// 检查是否存在缓存
- (BOOL)dataWithURL:(NSURL *)URL;

+ (instancetype)shareInstance;

- (void)resumeRequest:(NNResourceRequest *)request;
- (void)resumeAllRequest;

- (void)suspendRequest:(NNResourceRequest *)request;
- (void)suspendAllRequest;

- (void)cancelRequest:(NNResourceRequest *)request;
- (void)cancelAllRequest;

/// 检查缓存表中是否存在path的信息
- (BOOL)cacheListWithURLPath:(NSString *)path;

/// 暂停任务
- (void)suspend:(NSString *)URLPath;

/// 开始任务/恢复任务
- (void)resume:(NSString *)URLPath;

/// 取消任务
- (void)cancel:(NSString *)URLPath;

/// 缓存列表中的数据
- (NSArray <NNResourceRequest *>*)requestFormCacheList;

@end
