//
//  HJDownloadManager.m
//  HJNetworkService
//
//  Created by WHJ on 16/7/5.
//  Copyright © 2016年 WHJ. All rights reserved.
//

#import "HJDownloadManager.h"
#import "AppDelegate.h"
#import "HJDownloadHeaders.h"

@interface HJDownloadManager ()<NSURLSessionDownloadDelegate>{
    NSMutableArray *_downloadModels;
    NSMutableArray *_completeModels;
    NSMutableArray *_downloadingModels;
}

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSURLSession *backgroundSession;



@end



@implementation HJDownloadManager


#pragma mark - Single Method
static id instace = nil; 
+ (id)allocWithZone:(struct _NSZone *)zone 
{ 
    if (instace == nil) { 
        static dispatch_once_t onceToken; 
        dispatch_once(&onceToken, ^{ 
            instace = [super allocWithZone:zone];
            [[NSNotificationCenter defaultCenter] addObserver:instace selector:@selector(saveDownloadModels) name:UIApplicationWillTerminateNotification object:nil];
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:hj_UIApplicationWillTerminate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }); 
    } 
    return instace; 
} 

- (instancetype)init
{
    return instace;
}

+ (instancetype)sharedManager 
{ 
    return [[self alloc] init]; 
}

- (id)copyWithZone:(struct _NSZone *)zone
{ 
    return instace;
} 

- (id)mutableCopyWithZone:(struct _NSZone *)zone{
    return instace;
}


#pragma mark - Public Method

- (void)addDownloadModel:(HJDownloadModel *)model{
    if (![self checkExistWithDownloadModel:model]) {
        [self.downloadModels addObject:model];
    }
}


- (void)addDownloadModels:(NSArray<HJDownloadModel *> *)models{
    if ([models isKindOfClass:[NSArray class]]) {
        [models enumerateObjectsUsingBlock:^(HJDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HJDownloadModel *downloadModel = obj;
            if (![self checkExistWithDownloadModel:downloadModel]) {
                [self.downloadModels addObject:downloadModel];
            }
        }];
    }
}



- (void)startWithDownloadModel:(HJDownloadModel *)model{
    
    if (model.status == kHJDownloadStatus_Running) {
        return;
    }
    
    if (model.status != kHJDownloadStatusCompleted) {
        model.status = kHJDownloadStatus_Running;
    }

    if (model.operation == nil) {
        model.operation = [[HJDownloadOperation alloc]initWithDownloadModel:model andSession:self.backgroundDownload?self.backgroundSession:self.session];
        [self.queue addOperation:model.operation];
        [model.operation start];
    }else{
        [model.operation resume];
    }
    
}


- (void)suspendWithDownloadModel:(HJDownloadModel *)model{
    if (model.status != kHJDownloadStatusCompleted) {
        [model.operation suspend];
    }
}


- (void)resumeWithDownloadModel:(HJDownloadModel *)model{
    if (model.status != kHJDownloadStatusCompleted) {
        [model.operation resume];
    }
    
}

- (void)stopWithDownloadModel:(HJDownloadModel *)model{
    if (model.status != kHJDownloadStatusCompleted) {
        [model.operation cancel];
    }
}



- (void)startAllDownloadTasks;{
    
    [self operateTasksWithOperationType:kHJOperationType_start];
}



- (void)suspendAllDownloadTasks{
    
   [self operateTasksWithOperationType:kHJOperationType_suspend];
}



- (void)resumeAllDownloadTasks{
    
    [self operateTasksWithOperationType:kHJOperationType_resume];
}



- (void)stopAllDownloadTasks{
    
    [self operateTasksWithOperationType:kHJOperationType_stop];
}


- (void)saveDownloadModels{
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:hj_UIApplicationWillTerminate];
    [[NSUserDefaults standardUserDefaults] synchronize];
    __weak typeof(self) weakSelf = self;
    [self.downloadModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HJDownloadModel *model = obj;
        [weakSelf suspendWithDownloadModel:model];
        if (idx == (_downloadModels.count - 1)) {
            [self saveData];
        }
    }];
}

- (void)saveData{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:hj_savedDownloadModelsFilePath error:nil];
    BOOL flag = [NSKeyedArchiver archiveRootObject:self.downloadModels toFile:hj_savedDownloadModelsFilePath];
    NSLog(@"下载数据保存-%@",flag?@"成功!":@"失败");
}


#pragma mark - Private Method
-(BOOL)checkExistWithDownloadModel:(HJDownloadModel *)model{
    __block BOOL exist = NO;
    [self.downloadModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HJDownloadModel *tmpModel = obj;
        if ([tmpModel.urlString isEqualToString:model.urlString]) {
            exist = YES;
        }
    }];

    return exist;
}


- (void)operateTasksWithOperationType:(HJOperationType)operationType{
    __weak typeof(self) weakSelf = self;
    [self.downloadModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HJDownloadModel *downloadModel = obj;
        switch (operationType) {
            case kHJOperationType_start:
                [weakSelf startWithDownloadModel:downloadModel];
                break;
            case kHJOperationType_suspend:
                [weakSelf suspendWithDownloadModel:downloadModel];
                break;
            case kHJOperationType_resume:
                [weakSelf resumeWithDownloadModel:downloadModel];
                break;
            case kHJOperationType_stop:
                [weakSelf stopWithDownloadModel:downloadModel];
                break;
            default:
                break;
        }
    }];
}

#pragma mark - Setters/Getters
- (NSMutableArray *)downloadModels{

    if (!_downloadModels) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL exist = [fileManager fileExistsAtPath:hj_savedDownloadModelsFilePath isDirectory:nil];
        
        if (exist) {
          _downloadModels = [NSKeyedUnarchiver  unarchiveObjectWithFile:hj_savedDownloadModelsFilePath];
            NSError *error = nil;
            [fileManager removeItemAtPath:hj_savedDownloadModelsFilePath error:&error];
        }else{
            _downloadModels = [NSMutableArray array];
        }
    }
    return _downloadModels;
}

- (NSMutableArray *)completeModels{
    __block  NSMutableArray *tmpArr = [NSMutableArray array];
    if (self.downloadModels) {
            [self.downloadModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HJDownloadModel *model = obj;
            if (model.status == kHJDownloadStatusCompleted) {
                [tmpArr addObject:model];
            }
        }];
    }
    return tmpArr;
}


- (NSMutableArray *)downloadingModels{
    __block  NSMutableArray *tmpArr = [NSMutableArray array];
    if (self.downloadModels) {
        [self.downloadModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HJDownloadModel *model = obj;
            if (model.status != kHJDownloadStatusCompleted) {
                [tmpArr addObject:model];
            }
        }];
    }
    return tmpArr;
}



- (NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount = 5;
    }
    return _queue;
}


- (void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount{
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    self.queue.maxConcurrentOperationCount = _maxConcurrentOperationCount;
}


- (NSURLSession *)session{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        //不能穿self.queue
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

    }
    return _session;
}

- (NSURLSession *)backgroundSession{
    if (!_backgroundSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[[NSBundle mainBundle]bundleIdentifier]];
        //不能穿self.queue
        _backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

    }
    return _backgroundSession;
}

- (NSURLSession *)currentSession{
    return self.backgroundDownload?self.backgroundSession:self.session;
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;{

    if (downloadTask.downloadModel.destinationPath) {
        NSURL *toURL = [NSURL fileURLWithPath:downloadTask.downloadModel.destinationPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        //下载完成后 转移文件
        [fileManager moveItemAtURL:location toURL:toURL error:&error];
        downloadTask.downloadModel.resumeData = nil;
    }
    
    [downloadTask.downloadModel.operation downloadFinished];
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;{
    double byts = totalBytesWritten * 1.0 / 1024 /1024;
    double total = totalBytesExpectedToWrite * 1.0 / 1024 /1024;
    NSString *text = [NSString stringWithFormat:@"%.1lfMB/%.1lfMB",byts,total];
    CGFloat progress = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        downloadTask.downloadModel.statusText = text;
        downloadTask.downloadModel.progress = progress;
    });
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes;{

    double byts = fileOffset * 1.0 / 1024 /1024;
    double total = expectedTotalBytes * 1.0 / 1024 /1024;
    NSString *text = [NSString stringWithFormat:@"%.1lfMB/%.1lfMB",byts,total];
    CGFloat progress = fileOffset * 1.0 / expectedTotalBytes;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        downloadTask.downloadModel.statusText = text;
        downloadTask.downloadModel.progress = progress;
    });

}

//任务完成回调  可能有错误
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error;{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (!error) {
            task.downloadModel.status = kHJDownloadStatusCompleted;
            [task.downloadModel.operation downloadFinished];
        }else if (task.downloadModel.status == kHJDownloadStatus_suspended){
            
        }else if (task.downloadModel.status == kHJDownloadStatusCancel){
        
        }else if ( [error code]<0){
            // 网络异常
            task.downloadModel.status = kHJDownloadStatusFailed;
        }
        
    });
}


- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    //后台任务下载完成回调
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void(^completeHandler)() = appDelegate.backgroundSessionCompletionHandler;
        completeHandler();
        appDelegate.backgroundSessionCompletionHandler = nil;
    }
}

@end
