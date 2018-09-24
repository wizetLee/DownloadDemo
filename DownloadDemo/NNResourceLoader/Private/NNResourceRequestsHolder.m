//
//  NNResourceRequestsHolder.m
//   
//
//  Created by liweizhao on 2018/9/13.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "NNResourceRequestsHolder.h"
#import "NNResourceRequest+Private.h"

@implementation NNResourceRequestsHolder

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _defaultConfig];
    }
    return self;
}

- (void)_defaultConfig {
    _requestContainer = [NSMutableArray array];
}

- (void)removeAllRequests {
    for (NNResourceRequest *request in self.requestContainer) {
        request.NN_Holder = nil;
    }
    [self.requestContainer removeAllObjects];
}

- (void)removeRequest:(NNResourceRequest *)request {
    if ([_requestContainer containsObject:request]) {
        request.NN_Holder = nil;
        [_requestContainer removeObject:request];
    }
}

- (void)addRequest:(NNResourceRequest *)request {
    if (request) {
        if ([_requestContainer containsObject:request]) {
            
        } else {
            request.NN_Holder = self;
            [_requestContainer addObject:request];
        }
    }
}

- (void)cancelRequest:(NNResourceRequest *)request {
    if (self.requestContainer.count < 2) {
        [request.NN_Holder.task cancel];
    } else {
        if (request.canceled) {
            request.canceled(request.URLPath);
        }
        [self removeRequest:request];
    }
}

- (void)suspendRequest:(NNResourceRequest *)request {
    if (self.requestContainer.count < 2) {
        [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            // - (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error 中处理resumeData
            /*
             Cancels a download and calls a callback with resume data for later use.
             A download can be resumed only if the following conditions are met:
             1、The resource has not changed since you first requested it（资源不曾发生改变）
             2、The task is an HTTP or HTTPS GET request（get请求）
             3、The server provides either the ETag or Last-Modified header (or both) in its response（response中含有ETag or Last-Modified 相应头字段）
             4、The server supports byte-range requests（服务端支持断点请求）
             5、The temporary file hasn’t been deleted by the system in response to disk space pressure（tmp中的临时文件存在）
             */
        }];
    } else {
        if (request.pause) {
            request.pause(request.URLPath);
        }
        [self removeRequest:request];
    }
}

//- (void)dealloc {
//    NSLog(@"%s__%@", __func__, self.class);
//}

@end
