//
//  HJDownloadOperation.m
//  HJNetworkService
//
//  Created by WHJ on 16/7/5.
//  Copyright © 2016年 WHJ. All rights reserved.
//

#import <objc/runtime.h>
#import "HJDownloadHeaders.h"

#define kKVOBlock(KEYPATH,BLOCK)\
[self willChangeValueForKey:KEYPATH];\
BLOCK();\
[self didChangeValueForKey:KEYPATH];


@interface HJDownloadOperation (){

    BOOL _executing;
    BOOL _finished;

}

@property (nonatomic ,strong)NSURLSession *session;

@property (nonatomic ,strong)NSURLSessionDownloadTask *downloadTask;

@end


static const NSTimeInterval kTimeoutInterval = 60;

static NSString * const kIsExecuting = @"isExecuting";

static NSString * const kIsCancelled = @"isCancelled";

static NSString * const kIsFinished = @"isFinished";

@implementation HJDownloadOperation

MJCodingImplementation

-(instancetype)initWithDownloadModel:(HJDownloadModel *)downloadModel andSession:(NSURLSession *)session{
    self = [super init];
    if (self) {
        self.downloadModel = downloadModel;
        self.session = session;
        [self startRequest];
    }
    return self;
}


- (void)dealloc{
    self.downloadTask = nil;
}


#pragma mark - Public Method
- (void)startRequest{
    
    NSURL *url = [NSURL URLWithString:self.downloadModel.urlString];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeoutInterval];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    
    [self setupDownloadTask];

}

- (void)setupDownloadTask{
    self.downloadTask.downloadModel = self.downloadModel;
}


- (void)setDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
    if (_downloadTask != downloadTask) {
        _downloadTask = downloadTask;
    }
    if (!self.downloadTask) {
        [self.downloadTask addObserver:self
                            forKeyPath:@"state"
                               options:NSKeyValueObservingOptionNew
                               context:nil];
    }


}


- (void)suspend{
    if(self.downloadTask){
        __weak __typeof(self)weakSelf = self;
        __block NSURLSessionDownloadTask *weakTask = self.downloadTask;
        __block BOOL isExecuting = _executing;
        
        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            //FIXME: 文件保存
            //保存已下载数据
            weakSelf.downloadModel.resumeData = resumeData;
//            [weakSelf moveDownloadFileWith:self.downloadTask];
        
            //置空下载任务
            weakTask = nil;
            isExecuting = NO;
            [weakSelf didChangeValueForKey:kIsExecuting];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.downloadModel.status = kHJDownloadStatus_suspended;
            });
        }];
        
        [self.downloadTask suspend];
    }
}

- (void)resume{
    if(self.downloadModel.status == kHJDownloadStatusCompleted){
        return;
    }
    
    self.downloadModel.status = kHJDownloadStatus_Running;
    
    if (self.downloadModel.resumeData) {//恢复下载
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:self.downloadModel.destinationPath isDirectory:nil]) {
            NSError *error = nil;
            [fileManager moveItemAtPath:self.downloadModel.destinationPath toPath:self.downloadModel.tmpFilePath error:&error];
            NSLog(@"%@",error);
        }
        
        self.downloadTask = [self.session downloadTaskWithResumeData:self.downloadModel.resumeData];
        [self setupDownloadTask];
    }else if (!self.downloadTask || (self.downloadTask.state == NSURLSessionTaskStateCompleted && self.downloadModel.progress<1.0 )){//开始下载
        [self startRequest];
    }
    
    kKVOBlock(kIsExecuting, ^{
        [self.downloadTask resume];
        _executing = YES;
    });
    
}

- (void)downloadFinished{
    [self completeOperation];
}



- (void)completeOperation{
    [self willChangeValueForKey:kIsFinished];
    [self willChangeValueForKey:kIsExecuting];

    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:kIsExecuting];
    [self didChangeValueForKey:kIsFinished];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{

    if ([keyPath isEqualToString:@"state"]) {
        NSInteger state = [[object objectForKey:@"new"]integerValue];

        dispatch_async(dispatch_get_main_queue(), ^{
            switch (state) {
                case NSURLSessionTaskStateSuspended:
                    self.downloadModel.status = kHJDownloadStatus_suspended;
                    break;
                case NSURLSessionTaskStateCompleted:{
                    if (self.downloadModel.progress>=1.0f) {
                        self.downloadModel.status = kHJDownloadStatusCompleted;
                    }else{
                        self.downloadModel.status = kHJDownloadStatus_suspended;
                    }
                }
                    break;
                default:
                    break;
            }

        });
        
    }

}

#pragma mark - Override Method

- (void)start{
    //重写start方法时，要做好isCannelled的判断
    if (self.cancelled) {
        kKVOBlock(kIsFinished, ^{
            _finished = YES;
        });
        return;
    }

    kKVOBlock(kIsExecuting, ^{
        if (self.downloadModel.resumeData) {
            [self resume];
        }else{
            [self.downloadTask resume];
            self.downloadModel.status = kHJDownloadStatus_Running;
        }
        _executing = YES;
    });
}

- (BOOL)isExecuting{
    return _executing;
}


- (BOOL)isFinished{
    return _finished;
}

- (BOOL)isConcurrent{
    return YES;
}


- (void)cancel{
    kKVOBlock(kIsCancelled, ^{
        [super cancel];
        [self.downloadTask cancel];
        self.downloadTask = nil;
    });
    
    [self completeOperation];
}


#pragma mark - Private Method
- (void)moveDownloadFileWith:(NSURLSessionDownloadTask *)downloadTask{
    //拉取属性
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self.downloadTask class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        
        if ([@"downloadFile" isEqualToString:propertyName]){
            id propertyValue = [downloadTask valueForKey:(NSString *)propertyName];
            unsigned int downloadFileoutCount, downloadFileIndex;
            objc_property_t *downloadFileproperties = class_copyPropertyList([propertyValue class], &downloadFileoutCount);
            for (downloadFileIndex = 0; downloadFileIndex < downloadFileoutCount; downloadFileIndex++){
                
                objc_property_t downloadFileproperty = downloadFileproperties[downloadFileIndex];
                const char* downloadFilechar_f =property_getName(downloadFileproperty);
                NSString *downloadFilepropertyName = [NSString stringWithUTF8String:downloadFilechar_f];
                if([@"path" isEqualToString:downloadFilepropertyName]){
                    
                    id downloadFilepropertyValue = [propertyValue valueForKey:(NSString *)downloadFilepropertyName];
                    downloadTask.downloadModel.tmpFilePath = downloadFilepropertyValue;
                    NSError *error = nil;
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager moveItemAtPath:downloadFilepropertyValue toPath:downloadTask.downloadModel.destinationPath error:&error];
                    
                    if (error) {
                        NSLog(@"暂停下载:%@",error);
                    }else{
                        NSLog(@"暂停下载，文件移动成功!");
                    }
                    break;
                }
            }
            free(downloadFileproperties);
        }else{
            continue;
        }
    }
    free(properties);

}






+ (NSArray *)mj_ignoredCodingPropertyNames{
    return @[@"downloadTask",@"session",@"cancelled",@"concurrent",
             @"asynchronous",@"ready",@"dependencies"];
}

@end
