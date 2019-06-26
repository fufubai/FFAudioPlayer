//
//  FFSQLiteTool.h
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/25/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFSQLiteTool : NSObject
/**
 *  创建数据库和表
 */
+ (void)createTable;

/**
 *  添加下载的音频数据
 */
+ (void)addDownloadMusicWithTitleName:(NSString *)titleName musicUrl:(NSString *)urlString pictureData:(NSData *)picData musicData:(NSData *)musicData;

/**
 *  根据点击的tableview查询对应的已下载音频数据
 */
+ (NSDictionary *)queryDownloadMusicWithTitleName:(NSString *)titleName;

+ (BOOL)deleteDownloadMusicWithMusicUrl:(NSString *)musicUrl;

/**
 *  查询所有已下载的音频数据
 */
+ (NSArray *)queryAllDownloadMusic;
@end

NS_ASSUME_NONNULL_END
