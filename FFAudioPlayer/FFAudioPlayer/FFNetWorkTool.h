//
//  FFNetWorkTool.h
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/17/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^successData)(BOOL success,NSString *audioStr);

@interface FFNetWorkTool : NSObject
/**
 * 创建单例
 */
+ (instancetype)shareNetWorkTool;

/**
 * 创建请求POST
 */
- (void)doPostWithURL:(NSString *)urlsString success:(successData)success;

@end

NS_ASSUME_NONNULL_END
