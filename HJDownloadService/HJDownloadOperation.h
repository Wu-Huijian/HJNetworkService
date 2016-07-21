//
//  HJDownloadOperation.h
//  HJNetworkService
//
//  Created by WHJ on 16/7/5.
//  Copyright © 2016年 WHJ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HJDownloadModel;

@interface HJDownloadOperation : NSOperation


@property (nonatomic, weak) HJDownloadModel * downloadModel;

@property (nonatomic, strong, readonly) NSURLSessionDownloadTask * downloadTask;

-(instancetype)initWithDownloadModel:(HJDownloadModel *)downloadModel andSession:(NSURLSession *)session;


- (void)suspend;
- (void)resume;
- (void)downloadFinished;

@end
