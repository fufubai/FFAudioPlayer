//
//  FFPlayer.h
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/18/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFPlayer : NSObject

@property (nonatomic, strong) AVPlayer  *avPlayer;//播放网络音频
@property (nonatomic, strong) AVAudioPlayer  *audioPlayer;//播放网络音频
@property (nonatomic,strong)AVPlayerItem * songItem;
@property (nonatomic,assign)BOOL isPlaying;//播放状态
@property (nonatomic,assign)BOOL isLocal;//播放本地音频
@property (nonatomic,copy)NSString *musicUrl;



- (void)playWithMusicUrl:(NSString *)musicUrl;
- (void)playLocalMusic:(NSData *)musicData;

+(instancetype)musicTool;

- (void)pause;
- (void)play;

- (CGFloat)totalTime;
- (CGFloat)currentTime;
- (CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
