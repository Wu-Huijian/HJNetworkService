//
//  HJDownloadManager.h
//  HJNetworkService
//
//  Created by WHJ on 16/7/5.
//  Copyright © 2016年 WHJ. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, HJOperationType) {
    kHJOperationType_start,
    kHJOperationType_suspend ,
    kHJOperationType_resume,
    kHJOperationType_stop
};

#define kHJDownloadManager [HJDownloadManager sharedManager]

@class HJDownloadModel;

@interface HJDownloadManager : NSObject


@property (nonatomic, strong, readonly) NSMutableArray * downloadModels;

@property (nonatomic, strong, readonly) NSMutableArray * completeModels;

@property (nonatomic, strong, readonly) NSMutableArray * downloadingModels;

@property (nonatomic, strong, readonly) NSURLSession * currentSession;

@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;

@property (nonatomic, assign) BOOL backgroundDownload;//是否后台下载

+ (instancetype)sharedManager;
/**
 *  添加下载对象
 */
- (void)addDownloadModel:(HJDownloadModel *)model;

- (void)addDownloadModels:(NSArray<HJDownloadModel *> *)models;

/**
 *  开始下载
 *
 *  @param model 下载模型
 *  @param background 是否支持后台下载
 */

- (void)startWithDownloadModel:(HJDownloadModel *)model;
/**
 *  暂停下载
 */
- (void)suspendWithDownloadModel:(HJDownloadModel *)model;
/**
 *  恢复下载
 */
- (void)resumeWithDownloadModel:(HJDownloadModel *)model;

/**
 *  取消下载
 */
- (void)stopWithDownloadModel:(HJDownloadModel *)model;




- (void)startAllDownloadTasks;

- (void)suspendAllDownloadTasks;

- (void)resumeAllDownloadTasks;

- (void)stopAllDownloadTasks;

/**
 *  保存数据(未实现)
 */
- (void)saveDownloadModels;

@end
