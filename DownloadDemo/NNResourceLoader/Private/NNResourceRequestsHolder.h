//
//  NNResourceRequestsHolder.h
//   
//
//  Created by liweizhao on 2018/9/13.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNResourceRequest.h"

@interface NNResourceRequestsHolder : NSObject

@property (nonatomic, strong) NSMutableArray <NNResourceRequest *> *requestContainer;

@property (nonatomic, strong) NSString *URLPath;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;


- (void)addRequest:(NNResourceRequest *)request;
- (void)removeRequest:(NNResourceRequest *)request;


- (void)cancelRequest:(NNResourceRequest *)request;
- (void)suspendRequest:(NNResourceRequest *)request;


- (void)removeAllRequests;

@end
