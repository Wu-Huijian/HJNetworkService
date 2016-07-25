//
//  CONST.h
//  HJNetworkService
//
//  Created by WHJ on 16/7/7.
//  Copyright © 2016年 WHJ. All rights reserved.
//

#import <Foundation/Foundation.h>




#define BasePath [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/Caches/"]

#define  hj_savedDownloadModelsFilePath [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/Caches/hj_savedDownloadModels"]



/**
 *  static const
 */

//程序是否将要结束运行
static NSString *const hj_UIApplicationWillTerminate = @"hj_UIApplicationWillTerminate";

