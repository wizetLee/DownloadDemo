//
//  NNResourceRequest.h
//   
//
//  Created by liweizhao on 2018/9/13.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNReasourceHeader.h"

/**
 请求状态：未开始、正在、暂停、完成、下载失败（超时）、无效任务
 配置：请求回调、进度回调
 检查：是否有断点任务、断点的文件进度
 时间：下载开始的时间（恢复的时间）、下载完成的时间统计
 
 同一个URL的情况:
 A B C
 取消A，不影响B，C的任务
 
 取消A与任务的状态无关
 */

/// 请求item
@interface NNResourceRequest : NSObject

@property (nonatomic, strong) NSString *URLPath;

/// 缓存路径
@property (nonatomic, strong, readonly) NSString *outputFilePath;

@property (nonatomic, assign, readonly) int64_t totalBytesWritten;
@property (nonatomic, assign, readonly) int64_t totalBytesExpectedToWrite;

/// 状态
@property (nonatomic, assign, readonly) NNResourceRequestType type;


@property (nonatomic, strong) NNResourceLoaderBeginCallback begin;
@property (nonatomic, strong) NNResourceLoaderProgressCallback progress;
@property (nonatomic, strong) NNResourceLoaderCompletionCallback completion;
@property (nonatomic, strong) NNResourceLoaderPauseCallback pause;
@property (nonatomic, strong) NNResourceLoaderCancelCallback canceled;

- (void)resume;
- (void)suspend;
- (void)cancel;

@end
