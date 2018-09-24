//
//  NNResourceCache.h
//  DownloadDemo
//
//  Created by liweizhao on 2018/9/17.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>


//TODO:  1、缓存清理算法

/// 文件、缓存相关
@interface NNResourceCache : NSObject

/// 缓存记录表


/// 缓存目录
@property (nonatomic, strong, readonly) NSString *cacheDirectory;


/// 尝试获取完整文件的路径
- (NSString *)filePathWithURLPath:(NSString *)URLPath;

/// 尝试保存文件到缓存目录
- (BOOL)saveFileWithURLPath:(NSString *)URLPath loaction:(NSURL *)location;

/// 尝试获取resumeData
- (NSData *)resumeDataWithURLPath:(NSString *)URLPath;

/// 尝试保存resumeData
- (BOOL)saveResumData:(NSData *)resumeData URLPath:(NSString *)URLPath;

/// 尝试写入resumeDataPlist
- (BOOL)writeToResumeDataPlistWithDic:(NSDictionary *)dic URLPath:(NSString *)URLPath;

/// 删除某个resumeDataPlist及相关信息（对应的cache/tmp目录中的文件缓存）
- (void)removeResumeDataPlistWithURLPath:(NSString *)URLPath;

/// 尝试将tmp中的文件移动到缓存目录
- (BOOL)moveTmpToCacheDirectory:(NSString *)fileName;

/// 尝试将缓存目录中的文件移动到tmp
- (BOOL)moveCacheDirectoryToTmp:(NSString *)fileName;

/// 尝试提取resumeData的数据为字典
- (NSDictionary *)resuemDataPlist:(NSData *)resumeData;

/// 尝试获取resumeData中的所在tmp文件夹的文件名
- (NSString *)fileNameOfResumeData:(NSData *)resumeData;

/// 清理无效缓存、非缓存表内的缓存（包括：不成对的文件信息等）
- (void)cleanInvalidCache;

/// 清理所有的缓存
- (void)clean;

@end
