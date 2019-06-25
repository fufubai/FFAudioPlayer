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

// 播放网络音频
- (void)playWithMusicUrl:(NSString *)musicUrl {
    if (musicUrl == nil) {
        return;
    }
    self.musicUrl = musicUrl;
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
- (void)playLocalMusic:(NSData *)musicData {
//    NSURL *urlFile = [NSURL fileURLWithPath:filePath];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:musicData error:nil];
    if (self.audioPlayer)
    {
        if ([self.audioPlayer prepareToPlay])
        {
            // 播放时，设置喇叭播放否则音量很小
            AVAudioSession *playSession = [AVAudioSession sharedInstance];
            [playSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [playSession setActive:YES error:nil];
            
            [self.audioPlayer play];
        }
    }
}


- (void)pause {
    self.isPlaying = NO;
    [self.avPlayer pause];
}

- (void)play {
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
