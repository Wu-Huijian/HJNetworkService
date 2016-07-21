//
//  HJDownloadManager.h
//  HJNetworkService
//
//  Created by WHJ on 16/7/5.
//  Copyright © 2016年 WHJ. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, HJOperationType) {
    kHJOperationType_suspend = 1,
    kHJOperationType_resume,
    kHJOperationType_stop
};


@class HJDownloadModel;


@interface HJDownloadManager : NSObject


@property (nonatomic, strong, readonly) NSMutableArray * downloadModels;

@property (nonatomic, strong, readonly) NSMutableArray * completeModels;

@property (nonatomic, strong, readonly) NSMutableArray * downloadingModels;

@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;

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

- (void)startWithDownloadModel:(HJDownloadModel *)model background:(BOOL)background;
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

- (void)suspendAllDownloadTasks;

- (void)resumeAllDownloadTasks;

/**
 *  保存数据(未实现)
 */
- (void)saveDownloadModels;

@end
