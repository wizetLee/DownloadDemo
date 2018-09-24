//
//  DownloadCell.h
//  DownloadDemo
//
//  Created by liweizhao on 2018/9/17.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DownloadCell : UITableViewCell

@property (nonatomic, strong) void (^resumeTaskBlock)(void);
@property (nonatomic, strong) void (^suspendTaskBlock)(void);
@property (nonatomic, strong) void (^cancelTaskBlock)(void);

@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;

@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

- (void)updateWithModel:(id)model;


@end
