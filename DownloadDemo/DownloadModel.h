//
//  DownloadModel.h
//  DownloadDemo
//
//  Created by liweizhao on 2018/9/17.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNResourceRequest.h"

@interface DownloadModel : NSObject



@property (nonatomic, strong) NNResourceRequest *request;
@property (nonatomic, strong) NSString *path;

@end
