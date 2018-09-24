//
//  NNResourceRequest.m
//   
//
//  Created by liweizhao on 2018/9/13.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "NNResourceRequest.h"
#import "NNResourceLoader.h"
#import "NNResourceRequest+Private.h"

@interface NNResourceRequest()

@property (nonatomic, strong) NSString *outputFilePath;


@property (nonatomic, assign) int64_t totalBytesWritten;
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;


@property (nonatomic, assign) NNResourceRequestType type;

@end

@implementation NNResourceRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = NNResourceRequestType_Suspended;
    }
    return self;
}


- (void)configOutputFilePath:(NSString *)outputFilePath {
    self.outputFilePath = outputFilePath;
}


- (void)configTotalBytesWritten:(int64_t)totalBytesWritten {
    self.totalBytesWritten = totalBytesWritten;
}


- (void)configTotalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
}


- (void)configType:(NNResourceRequestType)type {
    self.type = type;
}


- (void)resume {
    [[NNResourceLoader shareInstance] resumeRequest:self];
    
}


- (void)suspend {
    [[NNResourceLoader shareInstance] suspendRequest:self];
}


- (void)cancel {
    [[NNResourceLoader shareInstance] cancelRequest:self];
}


- (void)dealloc {
    NSLog(@"%s__%@", __func__, self.class);
}

@end
