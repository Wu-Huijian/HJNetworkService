//
//  HJDownloadCell.m
//  HJNetworkService
//
//  Created by WHJ on 16/7/7.
//  Copyright © 2016年 WHJ. All rights reserved.
//

#import "HJDownloadCell.h"
#import "HJDownloadManager.h"
#import "HJDownloadModel.h"

@interface HJDownloadCell ()

@property(nonatomic ,strong)UIProgressView *progressV;

@property(nonatomic ,strong)UIButton *startBtn;

@property(nonatomic ,strong)UIButton *pauseBtn;

@property(nonatomic ,strong)UIButton *stopBtn;

@end

static const CGFloat btnWidth = 44;

@implementation HJDownloadCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        
    }
    return self;
}


- (void)setupUI{
    
    [self.contentView addSubview:self.progressV];
    [self.startBtn addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseBtn addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopBtn addTarget:self action:@selector(stopAction:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)setDownloadModel:(HJDownloadModel *)downloadModel{
        _downloadModel = downloadModel;
        [self.progressV setProgress:downloadModel.progress];
}

- (UIProgressView *)progressV{
    if (!_progressV) {
        _progressV = [[UIProgressView alloc]initWithFrame:CGRectMake(20, 20, 150, 4)];
        _progressV.progressTintColor = [UIColor greenColor];
        _progressV.backgroundColor = [UIColor grayColor];
      }
    return _progressV;
}


- (UIButton *)startBtn{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setTitle:@"开始" forState:UIControlStateNormal];
        [self.contentView addSubview:_startBtn];
        _startBtn.frame = CGRectMake(200, 2, btnWidth, 40);
        [_startBtn setBackgroundColor:[UIColor blueColor]];
        
    }
    return _startBtn;
}

- (UIButton *)pauseBtn{
    if (!_pauseBtn) {
        _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [self.contentView addSubview:_pauseBtn];
        _pauseBtn.frame = CGRectMake(200 + btnWidth + 5, 2, btnWidth, 40);
        [_pauseBtn setBackgroundColor:[UIColor blueColor]];
       
    }
    return _pauseBtn;
}

- (UIButton *)stopBtn{
    if (!_stopBtn) {
        _stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stopBtn setTitle:@"停止" forState:UIControlStateNormal];
        [self.contentView addSubview:_stopBtn];
        _stopBtn.frame = CGRectMake(200 + 2*btnWidth + 10, 2, btnWidth, 40);
        [_stopBtn setBackgroundColor:[UIColor blueColor]];
       
    }
    return _stopBtn;
}

#pragma mark - Event Response
- (void)startAction:(UIButton *)sender{
    
    [[HJDownloadManager sharedManager] startWithDownloadModel:self.downloadModel];
}


- (void)pauseAction:(UIButton *)sender{

        [[HJDownloadManager sharedManager] suspendWithDownloadModel:self.downloadModel];

}

- (void)stopAction:(UIButton *)sender{
    [[HJDownloadManager sharedManager] stopWithDownloadModel:self.downloadModel];
}



@end
