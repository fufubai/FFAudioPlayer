//
//  FFSQLiteTool.m
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/25/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import "FFSQLiteTool.h"
#import "FMDB.h"

@implementation FFSQLiteTool
static FMDatabase *_db;

+ (void)createTable{
    //1. 获取路径
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"musicDownload.db"];
    NSLog(@"filePath : %@", filePath);
    //2. 创建数据库
    _db = [FMDatabase databaseWithPath:filePath];
    //3. 判断是否打开成功
    if (![_db open]) {
        return;
    }
    //4. 创建表
    BOOL result1 = [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_download_music(id integer PRIMARY KEY, titleName text NOT NULL, picData blob,musicData blob NOT NULL, musicUrl text);"];
    if (result1) {
        NSLog(@"创建音乐表成功");
    }
}

//添加音频下载文件
+ (void)addDownloadMusicWithTitleName:(NSString *)titleName musicUrl:(NSString *)urlString pictureData:(NSData *)picData musicData:(NSData *)musicData{
    if ([_db open]) {
        int count = [_db executeUpdateWithFormat:@"INSERT INTO t_download_music(titleName,musicUrl,musicData,picData) VALUES(%@,%@,%@,%@)",titleName,urlString,musicData,picData];
//        int count = [_db executeUpdateWithFormat:@"INSERT INTO t_download_music(titleName,musicUrl,pictureUrl) VALUES(%@,%@,%@)",titleName,urlString,picString];
        
        if (count > 0) {
            NSLog(@"更新成功");
        }else{
            NSLog(@"更新失败");
        }
    }
    [_db close];
}

//查询此音频是否存在
+ (NSDictionary *)queryDownloadMusicWithPrimaryKey:(NSString *)key{
    if ([_db open]) {
        FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_download_music WHERE id=%@", key];
        if ([set next]) {
            NSDictionary *resultDic = @{@"titleName":[set objectForColumn:@"titleName"],@"musicData":[set objectForColumn:@"musicData"],@"picData":[set objectForColumn:@"picData"],@"musicUrl":[set objectForColumn:@"musicUrl"]};
            return resultDic;
        }
    }
    [_db close];
    return nil;
}
//根据下标删除某条音频
+ (BOOL)deleteDownloadMusicWithMusicUrl:(NSString *)musicUrl {
    if ([_db open]) {
        int count = [_db executeUpdateWithFormat:@"DELETE FROM t_download_music WHERE musicUrl=%@",musicUrl];
        [_db close];
        if (count > 0) {
            NSLog(@"删除成功");
            return YES;
        }else{
            NSLog(@"删除失败");
            return NO;
        }
    }
    return NO;
}
//查询所有音频数据
+ (NSArray *)queryAllDownloadMusic {
    NSMutableArray *mArray = [NSMutableArray array];
    if ([_db open]) {
        FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_download_music"];
        while ([set next]) {
            NSDictionary *resultDic = @{@"titleName":[set objectForColumn:@"titleName"],@"musicData":[set objectForColumn:@"musicData"],@"picData":[set objectForColumn:@"picData"],@"musicUrl":[set objectForColumn:@"musicUrl"]};
            [mArray addObject:resultDic];
        }
    }
    [_db close];
    return mArray.copy;
}


@end
