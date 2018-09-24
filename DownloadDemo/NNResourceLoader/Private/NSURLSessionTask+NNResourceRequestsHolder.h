//
//  NSURLSessionDownloadTask+NNResourceRequestsHolder.h
//   
//
//  Created by liweizhao on 2018/9/13.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NNResourceRequestsHolder;

@interface NSURLSessionTask (NNResourceRequestsHolder)

/// 弱引用
@property (nonatomic,   weak) NNResourceRequestsHolder *NN_Holder;

@end
