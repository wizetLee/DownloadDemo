//
//  NNResourceRequest+Private.m
//  DownloadDemo
//
//  Created by liweizhao on 2018/9/18.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "NNResourceRequest+Private.h"
#import <objc/runtime.h>


@implementation NNResourceRequest (Private)
@dynamic NN_Holder;

- (void)setNN_Holder:(NNResourceRequestsHolder *)NN_Holder {
    objc_setAssociatedObject(self, @selector(setNN_Holder:), NN_Holder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NNResourceRequestsHolder *)NN_Holder {
    return objc_getAssociatedObject(self, @selector(setNN_Holder:));
}


@end
