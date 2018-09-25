//
//  DownloadCell.m
//  DownloadDemo
//
//  Created by liweizhao on 2018/9/17.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "DownloadCell.h"
#import "NNResourceRequest.h"


@interface DownloadCell()


@property (nonatomic,   weak) NNResourceRequest *weakRequest;

@end

@implementation DownloadCell




- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithModel:(id)model {
    //  切断上一个model 与当前model之间的联系
    
    
    if ([model isKindOfClass:[NNResourceRequest class]]) {
        
        _weakRequest.begin = nil;
        _weakRequest.canceled = nil;
        _weakRequest.progress = nil;
        _weakRequest.completion = nil;
        
        NNResourceRequest *request = (NNResourceRequest *)model;
        _weakRequest = request;
        
        [self updateWithType:request.type];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(request) weakRequest = request;
        
        
//TODO: callback -> model -> UI
        
        request.begin = ^(NSString *URLPath) {
            NSLog(@"任务开始了");
            [weakSelf updateWithType:weakRequest.type];
        };
        request.canceled = ^(NSString *URLPath) {
            NSLog(@"任务已取消了");
            [weakSelf updateWithType:weakRequest.type];
        };
        request.pause = ^(NSString *URLPath) {
            NSLog(@"任务暂停了");
            [weakSelf updateWithType:weakRequest.type];
        };
        request.completion = ^(NSString *URLPath, NSString *outputFilePath, NNResourceRequestType type, NSDictionary *info) {
            if (outputFilePath) {
                NSLog(@"__任务完成了");
            } else if (type == NNResourceRequestType_Canceling) {
                NSLog(@"主动取消任务");
            } else if (type == NNResourceRequestType_TimeOut) {
                NSLog(@"任务超时");
            } else {
                NSLog(@"其他情况的被动取消任务");
                NSLog(@"info : %@", info);
            }
//FIXME: 绑定了控件和逻辑，需要修改～～～
            // 更新view
            [self updateWithType:type];
        };
        
        
        request.progress = ^(NSString *URLPath, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            
            NSString *str = [NSString stringWithFormat: @"bytesWritten : %lld", bytesWritten];
            str = [str stringByAppendingString:@"\n"];
            str = [str stringByAppendingString:[NSString stringWithFormat: @"totalBytesWritten : %lld", totalBytesWritten]];
            str = [str stringByAppendingString:@"\n"];
            str = [str stringByAppendingString:[NSString stringWithFormat: @"totalBytesExpectedToWrite : %lld", totalBytesExpectedToWrite]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.headlineLabel.text = str;
            });
        };
        
        self.resumeTaskBlock = ^{
            // 检查所有的相同任务，判断是否需要更新对应的状态
            [request resume];
        };
        
        self.suspendTaskBlock = ^{
            [request suspend];
        };
        self.cancelTaskBlock = ^{
            [request cancel];
        };
    }
    
}

- (void)updateWithType:(NNResourceRequestType)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (type) {
            case NNResourceRequestType_Canceling:
                self.headlineLabel.text = @"任务已取消";
                break;
                
            case NNResourceRequestType_Suspended:
                self.headlineLabel.text = @"任务等待中";
                break;
                
            case NNResourceRequestType_SavedSuccessfully:
                self.headlineLabel.text = @"任务保存成功";
                break;
            case NNResourceRequestType_IllConditioned:
                self.headlineLabel.text = @"任务条件缺失";
                break;
            case NNResourceRequestType_MoveFileError:
                self.headlineLabel.text = @"文件下载完成但移动到缓存目录出错";
                break;
            case NNResourceRequestType_ResumeDataSavingError:
                self.headlineLabel.text = @"断点文件保存出错";
                break;
            case NNResourceRequestType_TimeOut:
                self.headlineLabel.text = @"任务超时";
                break;
            default:
                break;
        }
    });
}

- (IBAction)startTask:(UIButton *)sender {
    _resumeTaskBlock();
}

- (IBAction)pauseTask:(UIButton *)sender {
    _suspendTaskBlock();
}
- (IBAction)cancel:(UIButton *)sender {
    _cancelTaskBlock();
}


@end
