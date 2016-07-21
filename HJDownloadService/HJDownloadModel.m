//
//  HJDownloadModel.m
//  HJNetworkService
//
//  Created by WHJ on 16/7/5.
//  Copyright © 2016年 WHJ. All rights reserved.
//

#import "HJDownloadModel.h"
#import "HJDownloadOperation.h"
#import "MJExtension.h"
@implementation HJDownloadModel

MJCodingImplementation

#define BasePath [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/Caches/"]

- (NSString *)destinationPath{
    if (!_destinationPath) {
        _destinationPath = [[BasePath stringByAppendingString:self.fileName] stringByAppendingString:self.fileFormat];
    }
    
    return _destinationPath;
}


- (NSString *)fileName{
    if (!_fileName) {
        NSTimeInterval timeInterval = [[NSDate date]timeIntervalSince1970];
        _fileName = [NSString stringWithFormat:@"%d",(int)timeInterval];
    }
    return _fileName;
}


- (void)setProgress:(CGFloat)progress{
    if (_progress != progress) {
        _progress = progress;
    }
     NSLog(@"%@%@==%@==%.1f%%",self.fileName,self.fileFormat,self.statusText,progress*100*1.0);
    if (self.progressChanged) {
        self.progressChanged(self);
    }
}


- (void)setStatus:(HJDownloadStatus)status{
    if (_status != status) {
        _status = status;
        [self setStatusTextWith:_status];
    }

    if (self.statusChanged) {
        self.statusChanged(self);
    }
}


- (void)setUrlString:(NSString *)urlString{
    _urlString = urlString;
    
    NSArray *urlArr = [_urlString componentsSeparatedByString:@"."];
    if (urlArr && urlArr.count>1) {
        self.fileFormat = [@"." stringByAppendingString:[urlArr lastObject]];
    }
}

- (void)setCompleteTime:(NSString *)completeTime{
    NSDateFormatter *fomatter = [[NSDateFormatter alloc]init];
    _completeTime = [fomatter stringFromDate:[NSDate date]];
}


- (void)setStatusTextWith:(HJDownloadStatus)status{
    _status = status;
    switch (status) {
        case kHJDownloadStatus_Running:
            self.statusText = @"正在下载";
            break;
        case kHJDownloadStatus_suspended:
            self.statusText = @"暂停下载";
            break;
        case kHJDownloadStatusFailed:
            self.statusText = @"下载失败";
            break;
        case kHJDownloadStatusCancel:
            self.statusText = @"取消下载";
            break;
        case kHJDownloadStatusWaiting:
            self.statusText = @"等待下载";
            break;
        case kHJDownloadStatusCompleted:{
            self.statusText = @"下载完成";
            self.progress = 1;
            self.completeTime = nil;
        }
            break;
        default:
            break;
    }

    NSLog(@"%@%@==%@",self.fileName,self.fileFormat,self.statusText);
}


+ (NSArray *)mj_ignoredCodingPropertyNames{
    
    return @[@"statusChanged",@"progressChanged"];
}
@end
