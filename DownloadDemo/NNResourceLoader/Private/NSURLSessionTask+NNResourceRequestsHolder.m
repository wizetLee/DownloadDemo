//
//  NSURLSessionDownloadTask+NNResourceRequestsHolder.m
//   
//
//  Created by liweizhao on 2018/9/13.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <objc/runtime.h>
#import "NSURLSessionTask+NNResourceRequestsHolder.h"

@implementation NSURLSessionTask (NNResourceRequestsHolder)

- (void)setNN_Holder:(NNResourceRequestsHolder *)NN_Holder {
    objc_setAssociatedObject(self, @selector(setNN_Holder:), NN_Holder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NNResourceRequestsHolder *)NN_Holder {
    return objc_getAssociatedObject(self, @selector(setNN_Holder:));
}


@end
