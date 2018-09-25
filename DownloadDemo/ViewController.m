//
//  ViewController.m
//  DownloadDemo
//
//  Created by liweizhao on 2018/9/15.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "ViewController.h"
#import "NNResourceLoader.h"
#import "DownloadCell.h"
#import "DownloadModel.h"
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSArray <DownloadModel *>*dataSource;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", NSHomeDirectory());
    
    NSArray *urlPaths = @[
                          @"https://github.com/airbnb/lottie-ios/archive/master.zip",
                        
                          @"https://devstreaming-cdn.apple.com/videos/app_store/Grailr_Developer_Insight/Grailr_Developer_Insight_hd.mp4?dl=1",
                           @"https://devstreaming-cdn.apple.com/videos/app_store/Grailr_Developer_Insight/Grailr_Developer_Insight_hd.mp4?dl=1",
                           @"https://devstreaming-cdn.apple.com/videos/app_store/Grailr_Developer_Insight/Grailr_Developer_Insight_hd.mp4?dl=1",
                          
                          @"https://cdn.pixabay.com/photo/2018/08/02/16/34/sunrise-3579931__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/02/27/21/55/belly-3186730__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/12/06/20/23/glasses-3002608__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/10/27/19/32/maple-leaves-2895335__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/08/13/00/58/raspberry-2635886__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/10/26/05/56/girl-2890175__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/01/04/11/38/spider-web-3060448__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/01/04/18/01/pepper-3061240__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/02/12/16/46/shoes-2060519__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/10/08/16/04/drop-2830413__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/10/28/09/51/winter-time-2896572__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/01/04/00/19/mountains-3059528__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/01/04/09/39/literature-3060241__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/07/19/01/40/skyscraper-2517650__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/12/23/22/12/orange-3036097__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/09/16/16/05/sea-2755901__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/01/26/20/54/port-3109757__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/01/25/21/49/wood-3107139__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/02/23/19/23/raspberry-3176371__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/02/27/06/30/skyscraper-3184798__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/02/09/15/00/girl-3141766__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/10/05/11/41/puffins-2819126__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/01/18/13/10/building-1989816__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/03/20/03/00/geyser-3242005__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/03/22/22/43/cocktails-3252160__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/04/16/10/02/star-trails-2234343__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/09/11/17/00/girl-2739669__480.jpg",
                          @"https://cdn.pixabay.com/photo/2018/04/13/23/55/strawberry-3317983__480.jpg",
                          @"https://cdn.pixabay.com/photo/2017/08/06/18/29/woman-2594934__480.jpg",
                          @"https://cdn.pixabay.com/photo/2015/08/22/20/10/dragonfly-901937__480.jpg",
                           ];
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true).firstObject;
    
    if ([[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:@"NNDownloadCache"] withIntermediateDirectories:true attributes:nil error:nil]) {
        
    };
    NSMutableArray *tmp = [NSMutableArray array];
//    url -> 缓存表查询 -> 缓存文件路径 -> 检查缓存合法性 -> 继续下载文件
    for (NSString *path in urlPaths) {
        
        DownloadModel *model = [DownloadModel new];
        model.path = path;
        
        NNResourceRequest *request = [[NNResourceRequest alloc] init];
        
        request.URLPath = path;
        model.request = request;
        [tmp addObject:model];
        
        [request resume];
    }
    
    _dataSource = tmp.copy;
    
    [self initViews];
}

- (void)initViews {
    _table = [[UITableView alloc] init];
    [self.view addSubview:_table];
    _table.frame = self.view.bounds;
    [_table registerNib:[UINib nibWithNibName:@"DownloadCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DownloadCell"];
    _table.delegate = self;
    _table.dataSource = self;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (DownloadCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadCell" forIndexPath:indexPath];
  
    NNResourceRequest *request = _dataSource[indexPath.row].request;
    
    [cell updateWithModel:request];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    _dataSource[indexPath.row].request.progress = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30 * 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
