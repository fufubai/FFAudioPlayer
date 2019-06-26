//
//  FFNetWorkTool.h
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/17/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^successData)(id response);

@interface FFNetWorkTool : NSObject
/**
 * 创建单例
 */
+ (instancetype)shareNetWorkTool;

/**
 * 创建请求POST
 */
+ (void)doPostWithURLString:(NSString *)urlString params:(id _Nullable)params success:(successData)success;

/**
 * 创建请求GET
 */
+ (void)doGetWithURLString:(NSString *)urlString params:(id _Nullable)params success:(successData)success;

/**
 *  创建下载请求
 */
+ (void)DownloadAudioWithUrlString:(NSString *)urlString params:(id _Nullable)params success:(successData)success;

@end

NS_ASSUME_NONNULL_END
