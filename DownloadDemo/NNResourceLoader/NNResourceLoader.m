//
//  NNResourceLoader.m
//   
//
//  Created by liweizhao on 2018/9/13.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NNResourceLoader.h"
#import "NNResourceRequestsHolder.h"
#import "NNResourceRequest+Private.h"
#import "NSURLSessionTask+NNResourceRequestsHolder.h"
#import "NNResourceCache.h"

@interface NNResourceLoader()<NSURLSessionDownloadDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate>

// 异步 检索文件、文件io、文件的读取工作、注意线程安全（不需要常驻线程）
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) NSUInteger maxConcurrentOperationCount;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableArray *holderContainer;

@property (nonatomic, strong) NSLock *lock;

/// NNResourceCache
@property (nonatomic, strong) NNResourceCache *cache;


@property (nonatomic, assign) NSUInteger maximumLoad;
@end

@implementation NNResourceLoader

+ (instancetype)shareInstance {
    static NNResourceLoader *resourceLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resourceLoader = [[NNResourceLoader alloc] init];
    });
    return resourceLoader;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _defaultConfig];
        [self _configNotification];
    }
    return self;
}


- (void)_defaultConfig {
    
    _lock = [[NSLock alloc] init];
    _queue = [[NSOperationQueue alloc] init];
    _queue.name = [NSStringFromClass([self class]) stringByAppendingString:@"Queue"];
    self.maxConcurrentOperationCount = 1;
    
    _holderContainer = [NSMutableArray array];
    _cache = [[NNResourceCache alloc] init];
    _maximumLoad = 0;
    
}


- (void)_configNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillTerminateNotification:) name:UIApplicationWillTerminateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidReceiveMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
}


- (NSString *)_keyForResumeInfoTempFileName {
    return @"NSURLSessionResumeInfoTempFileName";
}


- (void)_applicationWillTerminateNotification:(NSNotification *)sender {
    // 中断相关操作、保存相关信息
    [self suspendAllRequest];
}


- (void)_applicationDidReceiveMemoryWarningNotification:(NSNotification *)sender {
    // 清空无效缓存文件
    [self suspendAllRequest];
}


- (void)setMaxConcurrentOperationCount:(NSUInteger)maxConcurrentOperationCount {
    self.queue.maxConcurrentOperationCount = maxConcurrentOperationCount;
}


- (NSUInteger)maxConcurrentOperationCount {
    return self.queue.maxConcurrentOperationCount;
}


- (NSString *)cacheDirectory {
    return _cache.cacheDirectory;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSUInteger new = [change[@"new"] boolValue];
    NSUInteger old = [change[@"old"] boolValue];
   
    if (new == NSURLSessionTaskStateRunning
        && old == NSURLSessionTaskStateSuspended) {
        if ([object isKindOfClass:[NNResourceRequestsHolder class]]) {
            NNResourceRequestsHolder *holder = (NNResourceRequestsHolder *)object;
            for (NNResourceRequest *request in holder.requestContainer) {
                [request configType:NNResourceRequestType_Running];
                if (request.begin) {
                    request.begin(request.URLPath);
                }
            }
        }
    }
}


#pragma mark - Public
- (void)configMaximumLoad:(NSUInteger)maximumLoad {
    _maximumLoad = maximumLoad;
}


- (void)resumeRequest:(NNResourceRequest *)request {
    if (request.type == NNResourceRequestType_Running) {
        return;
    }
    
    // filter
    if (![request isKindOfClass:[NNResourceRequest class]]
        || !request.URLPath) {
        [_lock lock];
        NNResourceRequestType type = NNResourceRequestType_IllConditioned;
        [request configType:type];
        if (request.completion) {
            request.completion(nil, nil, type, nil);
        }
        [_lock unlock];
        return ;
    }
    
    NSString *URLPath = request.URLPath;
    NSString *filePath = [self.cache filePathWithURLPath:URLPath];
    if (filePath) {
        [_lock lock];
        NNResourceRequestType type = NNResourceRequestType_SavedSuccessfully;
        [request configType:type];
        if (request.completion) {
            request.completion(URLPath, filePath, type, nil);
        }
        [_lock unlock];
        return;
    }
   
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:_queue];
    }
    
    NNResourceRequestsHolder *holder = nil;
    
    
    [_lock lock];
    for (NNResourceRequestsHolder *tmpHolder in _holderContainer) {
        if ([tmpHolder.URLPath isEqualToString:URLPath]) {
            holder = tmpHolder;
            break;
        }
    }

    if (holder) {
        [holder addRequest:request];
    } else {
        
        NSURL *URL = [NSURL URLWithString:URLPath];
        NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
        // totalBytesExpectedToWrite : -1  https://stackoverflow.com/questions/23585432/totalbytesexpectedtowrite-is-1-in-nsurlsessiondownloadtask
        [URLRequest addValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
        NSURLSessionDownloadTask *task = nil;
        
        NSData *resumeData = [self.cache resumeDataWithURLPath:URLPath];
        
        if (resumeData) {
            task = [self.session downloadTaskWithResumeData:resumeData];
        } else {
            task = [self.session downloadTaskWithRequest:URLRequest];
        }
      
        
        holder = [[NNResourceRequestsHolder alloc] init];
        holder.task = task;
        holder.task.NN_Holder = holder;
        holder.URLPath = URLPath;
        
        // 状态监听
        [holder addObserver:self forKeyPath:@"task.state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
       
        
        // 内存引用
        [holder addRequest:request];
        [_holderContainer addObject:holder];
        // 磁盘缓存
        
        
        //FIXME: 修改
        // 正在下载的任务量控制
        if (_maximumLoad > 0) {
            NSLog(@"~~");
        } else {
            [task resume];
        }
      
    }
    [_lock unlock];
    
    return ;
}

- (void)suspendRequest:(NNResourceRequest *)request {
    if (request.type != NNResourceRequestType_Running) {
        return;
    }
    
    [_lock lock];
    NNResourceRequestsHolder *holder = request.NN_Holder;
    [holder suspendRequest:request];
    [_lock unlock];
    return ;
}


- (void)cancelRequest:(NNResourceRequest *)request {
    if (request.type != NNResourceRequestType_Running) {
        return;
    }
    
    [_lock lock];
    NNResourceRequestsHolder *holder = request.NN_Holder;
    [holder cancelRequest:request];
    [_lock unlock];
    return ;
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    NNResourceRequestsHolder *holder = downloadTask.NN_Holder;
    if (holder) {
        NSString *URLPath = holder.URLPath;
        if ([self.cache saveFileWithURLPath:URLPath loaction:location]) {
            NSString *outputFilePath = [self.cache filePathWithURLPath:URLPath];
            [_lock lock];
            for (NNResourceRequest *request in holder.requestContainer) {
                [request configType:NNResourceRequestType_SavedSuccessfully];
                [request configOutputFilePath:outputFilePath];
                if (request.completion) {
                    request.completion(URLPath, outputFilePath, NNResourceRequestType_SavedSuccessfully, nil);
                }
            }
            [_lock unlock];
        } else {
            // 返回location
            [_lock lock];
            for (NNResourceRequest *request in holder.requestContainer) {
                request.completion(URLPath, nil, NNResourceRequestType_MoveFileError, @{@"locaton" : location} );
            }
            [_lock unlock];
        }
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
        NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)task;
        
        NNResourceRequestsHolder *holder = downloadTask.NN_Holder;
        if (error && holder) {
            // 储存出错的数据
            NSString *URLPath = holder.URLPath;
            
            //TODO: 增加过滤不支持断点下载的处理(判断Content-Range？)
//            if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
//                NSHTTPURLResponse *response = (NSHTTPURLResponse *)downloadTask.response;
//                Accept-Ranges  Content-Range
//                 response.allHeaderFields[@"Content-Length"] && (response.allHeaderFields[@"Etag"] || response.allHeaderFields[@"Last-Modified"]
            
//            }
            
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            
            // 将文件从tmp移动到cache目录
            if (resumeData && [self.cache saveResumData:resumeData URLPath:URLPath]) {
                [_lock lock];
                // 更新状态
                for (NNResourceRequest *request in holder.requestContainer) {
                    [request configType:NNResourceRequestType_Suspended];
                    if (request.pause) {
                        request.pause(URLPath);
                    }
                }
                [_lock unlock];
            } else {
               
                [self.cache removeResumeDataPlistWithURLPath:URLPath];
                NNResourceRequestType type = NNResourceRequestType_Canceling;
                
                NSString *description = error.userInfo[@"NSLocalizedDescription"];
                
                if ([description isEqualToString:@"cancelled"]) {
                    // 主动取消任务
                } else if ([description isEqualToString:@"The request timed out."]) {
                    // 任务超时
                    type = NNResourceRequestType_TimeOut;
                } else {
                    // 被动取消任务（数据出错的情况）
                    // resumeData不存在/键值修改了导致/文件移动失败等原因
                    // need:清空resumeDataPlist及相关数据，下次任务需要重新下载
                    type = NNResourceRequestType_ResumeDataSavingError;
                }
                
                [_lock lock];
                for (NNResourceRequest *request in holder.requestContainer) {
                    [request configType:type];
                    if (request.completion) {
                        request.completion(URLPath, nil, type, nil);
                    }
                }
                [_lock unlock];
            }
        }
        
        
        [holder removeObserver:self forKeyPath:@"task.state"];
        holder.task = nil;
        [holder removeAllRequests];
        [_holderContainer removeObject:holder];
        downloadTask.NN_Holder = nil;
    }
   
}


/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

    NNResourceRequestsHolder *holder = downloadTask.NN_Holder;
    if (holder) {
        [_lock lock];
        for (NNResourceRequest *request in holder.requestContainer) {
            [request configTotalBytesWritten:totalBytesWritten];
            [request configTotalBytesExpectedToWrite:totalBytesExpectedToWrite];
            if (request.progress) {
                request.progress(holder.URLPath, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
            }
        }
         [_lock unlock];
    }
}


@end
