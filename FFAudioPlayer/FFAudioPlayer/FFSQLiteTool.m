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
    BOOL result1 = [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_download_music(id integer PRIMARY KEY, titleName text NOT NULL, musicUrl text NOT NULL,musicData blob NOT NULL, pictureUrl text);"];
    if (result1) {
        NSLog(@"创建音乐表成功");
    }
}

//添加音频下载文件
+ (void)addDownloadMusicWithTitleName:(NSString *)titleName musicUrl:(NSString *)urlString pictureUrl:(NSString *)picString data:(NSData *)data{
    if ([_db open]) {
        int count = [_db executeUpdateWithFormat:@"INSERT INTO t_download_music(titleName,musicUrl,musicData,pictureUrl) VALUES(%@,%@,%@,%@)",titleName,urlString,data,picString];
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
            NSDictionary *resultDic = @{@"titleName":[set objectForColumn:@"titleName"],@"musicData":[set objectForColumn:@"musicData"],@"pictureUrl":[set objectForColumn:@"pictureUrl"]};
            return resultDic;
        }
    }
    [_db close];
    return nil;
}
+ (NSArray *)queryAllDownloadMusic {
    NSMutableArray *mArray = [NSMutableArray array];
    if ([_db open]) {
        FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_download_music"];
        while ([set next]) {
            NSDictionary *resultDic = @{@"titleName":[set objectForColumn:@"titleName"],@"musicData":[set objectForColumn:@"musicData"],@"pictureUrl":[set objectForColumn:@"pictureUrl"]};
            [mArray addObject:resultDic];
        }
    }
    [_db close];
    return mArray.copy;
}


@end
