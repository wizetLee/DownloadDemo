//
//  NNResourceCache.m
//  DownloadDemo
//
//  Created by liweizhao on 2018/9/17.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "NNResourceCache.h"
#import "NSString+MD5.h"

// 缓存信息的键
#define NNResourceDidWritten @"totalBytesWritten"
#define NNResourceExpectedToWrite @"totalBytesExpectedToWrite"
#define NNResourceURLPath @"URLPath"

@interface NNResourceCache()

/// 保存已完成、未完成任务的URLPath，下载进度，
// 下载的信息 - 任务长度 - 进度位置 - 状态（待下载-正下载-暂停下载-取消下载-下载完成）
@property (nonatomic, strong) NSMutableArray *cachePlist;

@end

@implementation NNResourceCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _defaultConfig];
    }
    return self;
}


- (void)_defaultConfig {
    
    // 读取缓存表信息
    _cachePlist = [[NSUserDefaults standardUserDefaults] valueForKey:@"cacheList"];
    if (!_cachePlist) {
        _cachePlist = [NSMutableArray array];
    }
}


- (NSString *)cacheDirectory {
    return [self _createCacheDirectory];
}


- (NSString *)_createCacheDirectory {
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"NNDownloadCache"];
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
                                   withIntermediateDirectories:true
                                                    attributes:nil
                                                         error:&error]) {
        if (error) {
            NSAssert(0, @"考虑处理方案");
            cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true).firstObject;
        } else {
//            NSLog(@"创建目录成功：%@", cacheDirectory );
        }
    }
    return cacheDirectory;
}


/// 移动tmp文件到cache目录。  PS：检查cache目录是否存在文件->移除cache目录文件->移动文件
- (BOOL)moveTmpToCacheDirectory:(NSString *)filename {
    if (!filename) {
        return false;
    }
    NSString *tmp_TmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    NSString *cache_TmpFilePath = [self.cacheDirectory stringByAppendingPathComponent:[tmp_TmpFilePath lastPathComponent]];
    return [self moveOriginalPath:tmp_TmpFilePath destinationPath:cache_TmpFilePath];
}


/// PS:会将tmp目录中的文件先删除再移动。  PS：检查tmp目录是否存在文件->移除tmp目录文件->移动文件
- (BOOL)moveCacheDirectoryToTmp:(NSString *)filename {
    if (!filename) {
        return false;
    }
    NSString *tmp_TmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    NSString *cache_TmpFilePath = [self.cacheDirectory stringByAppendingPathComponent:[tmp_TmpFilePath lastPathComponent]];
    return [self moveOriginalPath:cache_TmpFilePath destinationPath:tmp_TmpFilePath];
}


/// 文件移动
- (BOOL)moveOriginalPath:(NSString *)originalPath destinationPath:(NSString *)destinationPath {
    NSError *error = nil;
    if ([self moveFileWithOriginalPath:originalPath destinationPath:destinationPath error:&error]) {
        return true;
    }
    
    return false;
}


- (BOOL)moveFileWithOriginalPath:(NSString *)originalPath destinationPath:(NSString *)destinationPath error:(NSError **)error {
    if ([[NSFileManager defaultManager] fileExistsAtPath:originalPath]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:error];
        }
        BOOL result = [[NSFileManager defaultManager] moveItemAtPath:originalPath toPath:destinationPath error:error];
        if (!result) {
            NSLog(@"移动文件失败...%@", (*error).debugDescription);
        }
        return result;
    } else {
//        NSLog(@"源文件不存在...%@", originalPath.lastPathComponent);
    }
    return false;
}


- (NSDictionary *)resuemDataPlist:(NSData *)resumeData {
    if (!resumeData) {
        return nil;
    }
    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:resumeData options:NSPropertyListImmutable format:NULL error:&error];
    if (!resumeDictionary || error) {
        return nil;
    }
    return resumeDictionary;
}


- (NSString *)filenameOfResumeData:(NSData *)resumeData {
    NSDictionary *resumeDictionary = [self resuemDataPlist:resumeData];
    if (resumeDictionary) {
        NSString *filename = resumeDictionary[[self _keyForResumeInfoTempfilename]];
        return filename;
    }
    return nil;
}


- (BOOL)writeToResumeDataPlistWithDic:(NSDictionary *)dic URLPath:(NSString *)URLPath {
    NSString *resumeDataPlistFilePath = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", URLPath.MD5Result]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resumeDataPlistFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:resumeDataPlistFilePath error:nil];
    }
    return [dic writeToFile:resumeDataPlistFilePath atomically:true];
}

- (void)removeResumeDataPlistWithURLPath:(NSString *)URLPath {
    if (!URLPath || URLPath.length < 1) {
        return;
    }
    
    NSString *resumeDataPlistFilePath = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", URLPath.MD5Result]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resumeDataPlistFilePath]) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:resumeDataPlistFilePath];
        NSString *filename = dic[[self _keyForResumeInfoTempfilename]];
        if (filename) {
            NSString *tmp_TmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
            NSString *cache_TmpFilePath = [self.cacheDirectory stringByAppendingPathComponent:[tmp_TmpFilePath lastPathComponent]];
            [[NSFileManager defaultManager] removeItemAtPath:tmp_TmpFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:cache_TmpFilePath error:nil];
        }
        
         [[NSFileManager defaultManager] removeItemAtPath:resumeDataPlistFilePath error:nil];
    }
}


- (NSData *)resumeDataWithURLPath:(NSString *)URLPath {
    
    NSData *resumeData = nil;
    NSString *resumeDataPlistPath = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", URLPath.MD5Result]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:resumeDataPlistPath]) {
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithContentsOfFile:resumeDataPlistPath];
        if (tmpDic && [self moveCacheDirectoryToTmp:tmpDic[[self _keyForResumeInfoTempfilename]]]) {
            resumeData = [NSData dataWithContentsOfFile:resumeDataPlistPath];
        } else {
            // resumeData源文件不存在或数据损坏（格式出错）
            
            NSLog(@"resumeData源文件不存在或数据损坏（格式出错) PS：多是由于crash造成的数据缺失");
            [self removeResumeDataPlistWithURLPath:resumeDataPlistPath];
            //移除此plist文件
            [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:resumeDataPlistPath] error:nil];
        }
    }
    
    return resumeData;
}

- (BOOL)saveResumData:(NSData *)resumeData URLPath:(NSString *)URLPath {
    if (!resumeData || !URLPath) {
        return false;
    }
    
    BOOL result = false;
    
    NSDictionary *resumeDictionary = [self resuemDataPlist:resumeData];
    NSString *resumeDatafilename = resumeDictionary[[self _keyForResumeInfoTempfilename]];
#if DEBUG
    NSAssert(resumeDatafilename , @"更换filename的key，需要修改");
#endif
    
    if (URLPath
        && resumeDatafilename
        && [self moveTmpToCacheDirectory:resumeDatafilename]) {
       
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        for (NSString *key in resumeDictionary.allKeys) {
            if ([resumeDictionary[key] isKindOfClass:[NSData class]]) {
                
            } else {
                tmpDic[key] = resumeDictionary[key];
            }
        }
        result = [self writeToResumeDataPlistWithDic:tmpDic URLPath:URLPath];
        
    }
    
    return result;
}


- (NSString *)_keyForResumeInfoTempfilename {
    return @"NSURLSessionResumeInfoTempFileName";
}


//MARK: - Public
- (NSString *)filePathWithURLPath:(NSString *)URLPath {
    NSString *filename = [NSString stringWithFormat:@"%@", URLPath.MD5Result];
//        filename = [NSString stringWithFormat:@"%@.%@",URLPath.MD5Result, URL.pathExtension];

    NSString *filePath = [self.cacheDirectory stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    }
    return nil;
}


- (BOOL)saveFileWithURLPath:(NSString *)URLPath loaction:(NSURL *)location {
    BOOL result = true;
    
    NSString *filename = [NSString stringWithFormat:@"%@", URLPath.MD5Result];
    
    NSError *error = nil;
    NSString *filePath = [self.cacheDirectory stringByAppendingPathComponent:filename];
    if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:&error]) {
        result = false;
        
        if (error.code == 516) {
            NSLog(@"存在相同文件....an item with the same name already exists");
        } else {
            NSLog(@"移动文件失败：%@", error.description);
        }
    }
    
    return result;
}

@end
