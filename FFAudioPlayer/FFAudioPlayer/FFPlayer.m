//
//  FFPlayer.m
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/18/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import "FFPlayer.h"

@implementation FFPlayer

static FFPlayer *_INSTANCE;
static dispatch_once_t _onceToken;

+(instancetype)musicTool
{
    dispatch_once(&_onceToken, ^{
        _INSTANCE = [[FFPlayer alloc]init];
        //设置后台播放
        [[AVAudioSession sharedInstance]setActive:YES error:nil];
        [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
        
    });
    return _INSTANCE;
}

// 播放音频
- (void)playWithMusicName:(NSString *)musicName
{
    self.musicUrl = musicName;
    if ([musicName hasPrefix:@"http"]) {
        //1 网络音乐
        [self playWithMusicUrl:musicName];
    }else{
        //2 本地音乐
        [self playLocalMusic:musicName];
    }
}

// 播放网络音频
- (void)playWithMusicUrl:(NSString *)musicUrl {
    if (musicUrl == nil) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        //创建一个音乐播放器 对象
        NSURL *url = [NSURL URLWithString:musicUrl];
        self.songItem = [AVPlayerItem playerItemWithURL:url];
        //初始化player对象
        if (self.songItem) {
            self.avPlayer = [[AVPlayer alloc]initWithPlayerItem:self.songItem];
            [self.avPlayer play];
        }
        self.isPlaying = YES;
    });
}

// 播放本地音频
- (void)playLocalMusic:(NSString *)musicName {
    if (musicName == nil) {
        return;
    }
    //获取mp3的路径
    NSString *path = nil;
    if ([musicName hasPrefix:@"/Users"] || [musicName hasPrefix:@"/var"] || [musicName hasPrefix:@"file"]) {
        path = musicName;
    }else{
        path = [[NSBundle mainBundle]pathForResource:musicName ofType:nil];
    }
    if (path == nil) {
        return;
    }
    
    //初始化player对象
    NSURL *url = [NSURL fileURLWithPath:path];
    self.avPlayer = [[AVPlayer alloc] initWithURL:url];
    [self.avPlayer play];
}

- (void)pause; {
    self.isPlaying = NO;
    [self.avPlayer pause];
}

- (void)play; {
    self.isPlaying = YES;
    [self.avPlayer play];
}

- (void)playLast:(NSString *)musicUrl; {
    [self playWithMusicUrl:musicUrl];
}
- (void)playNext:(NSString *)musicUrl {
    [self playWithMusicUrl:musicUrl];
}

- (CGFloat)totalTime
{
    return CMTimeGetSeconds(self.avPlayer.currentItem.asset.duration);
}

- (CGFloat)currentTime
{
    return CMTimeGetSeconds(self.avPlayer.currentItem.currentTime);
}

- (CGFloat)progress
{
    return self.currentTime/self.totalTime;
}

@end
