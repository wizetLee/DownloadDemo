//
//  NNResourceRequest+Private.h
//  DownloadDemo
//
//  Created by liweizhao on 2018/9/18.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "NNResourceRequest.h"
#import "NNResourceRequestsHolder.h"


@interface NNResourceRequest (Private)

@property (nonatomic,   weak) NNResourceRequestsHolder *NN_Holder;

- (void)configOutputFilePath:(NSString *)outputFilePath;

- (void)configTotalBytesWritten:(int64_t)totalBytesWritten;
- (void)configTotalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

- (void)configType:(NNResourceRequestType)type;


@end
