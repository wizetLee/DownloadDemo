//
//  NNReasourceHeader.h
//   
//
//  Created by liweizhao on 2018/9/13.
//  Copyright © 2018年 wizet. All rights reserved.
//

#ifndef NNReasourceHeader_h
#define NNReasourceHeader_h

/// ResourceLoader的状态
typedef NS_ENUM(NSUInteger, NNResourceRequestType) {
    
    /// 未开始
    NNResourceRequestType_ = 10000,
    
    ///
    NNResourceRequestType_Suspended = 0,
    
    /// 正在下载
    NNResourceRequestType_Running = 1,
    
    
    /// 主动取消任务
    NNResourceRequestType_Canceling = 2,
    
    
    /// 完成的情况再下面区分
//    NNResourceRequestType_Completed = 3,
    
    /// 完成下载并保存成功
    NNResourceRequestType_SavedSuccessfully = 3,
    
    /// 条件不足
    NNResourceRequestType_IllConditioned = 4,
    
    /// 文件下载完成但移动到缓存目录出错
    NNResourceRequestType_MoveFileError = 5,
    
    /// 保存断点文件出错
    NNResourceRequestType_ResumeDataSavingError = 6,
    
    /// 任务超时
    NNResourceRequestType_TimeOut = 7,
};




typedef void (^NNResourceLoaderBeginCallback)(NSString *URLPath);

/// 下载进度
typedef void (^NNResourceLoaderProgressCallback)(NSString *URLPath, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

/// 完成(失败/成功)
typedef void (^NNResourceLoaderCompletionCallback)(NSString *URLPath, NSString *outputFilePath, NNResourceRequestType type, NSDictionary *info);

/// 主动暂停/自动暂停（关闭APP、网络超时等原因）
typedef void (^NNResourceLoaderPauseCallback)(NSString *URLPath);

/// 主动取消任务
typedef void (^NNResourceLoaderCancelCallback)(NSString *URLPath);


#endif /* NNReasourceHeader_h */
