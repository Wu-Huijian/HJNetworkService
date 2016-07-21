
//
//  ViewController.m
//  HJNetworkService
//
//  Created by WHJ on 16/7/5.
//  Copyright © 2016年 WHJ. All rights reserved.
//

#import "ViewController.h"
#import "HJDownloadCell.h"
#import "HJDownloadManager.h"
#import "HJDownloadModel.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{

    NSArray *downloadURLs;
    
    NSArray *downloadModels;
}


@property(nonatomic ,strong)UITableView *tableView;

@end

static  NSString * const cellIdentifier = @"HJDownloadCell";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupUI];

    [self initW];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)initW{
    downloadURLs = @[
                     @"http://dlsw.baidu.com/sw-search-sp/soft/ca/13442/Thunder_dl_7.9.43.5054.1456898740.exe",
                     @"http://dlsw.baidu.com/sw-search-sp/soft/90/25706/QQMusic_mac_3.1.2.1.1459849889.dmg",
                     @"http://sw.bos.baidu.com/sw-search-sp/software/bfe69c1ecac/QQ_4.2.1_mac.dmg",
                     @"http://sw.bos.baidu.com/sw-search-sp/software/1e17bc85c98/iQIYIMedia_002_4.7.9.dmg",
                     @"http://dlsw.baidu.com/sw-search-sp/soft/4a/25763/SHPlayer_2.5_mac.1459930380.pkg"
                     ];
    
    
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:downloadURLs.count];
    for (NSString *urlStr in downloadURLs) {
        HJDownloadModel *model = [[HJDownloadModel alloc]init];
        model.urlString = urlStr;
        [models addObject:model];
    }
    [[HJDownloadManager sharedManager] addDownloadModel:[models firstObject]];
    [models removeObjectAtIndex:0];
    [[HJDownloadManager sharedManager] addDownloadModels:models];
    downloadModels = [HJDownloadManager sharedManager].downloadModels;
}

- (void)setupUI{

    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor purpleColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    [tableView registerClass:[HJDownloadCell class] forCellReuseIdentifier:cellIdentifier];
    self.tableView = tableView;

}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return downloadModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HJDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    HJDownloadModel *downloadModel = downloadModels[indexPath.row];
    cell.downloadModel = downloadModel;
    
    downloadModel.progressChanged = ^(HJDownloadModel *downloadModel){
        cell.downloadModel = downloadModel;
    };
    
    
    downloadModel.statusChanged = ^(HJDownloadModel *downloadModel){
        cell.downloadModel = downloadModel;
    };
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
