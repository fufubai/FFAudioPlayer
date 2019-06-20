//
//  FFPlayViewViewController.m
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/18/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import "FFPlayViewViewController.h"
#import <Masonry.h>
#import <SDWebImage.h>
#import "FFPlayer.h"

@interface FFPlayViewViewController ()
@property (nonatomic, assign) CGFloat playbackTime;
@property (nonatomic, strong) NSTimer *playerTimer;
@property (nonatomic, strong) UIImageView *revolveImage;
@property (nonatomic, strong) UILabel *nowTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UILabel *musicTitleLabel;
@property (nonatomic, strong) UIProgressView *playerProgress;
@property (nonatomic, strong) UISlider *sliderProgress;
// 进度条滑动过程中 防止因播放器计时器更新进度条的进度导致滑动小球乱动
@property (nonatomic, assign) BOOL sliding;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, assign) BOOL play;
@property (nonatomic, assign) CGFloat playheadTime;
@property (nonatomic, assign) CGFloat totalTime;
@property (nonatomic, strong) UIButton *lastButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)CALayer *layer;//图片旋转功能
@property (nonatomic,strong)CABasicAnimation *animation;
@end

@implementation FFPlayViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    [self createView];
    
    [self startPlay];
}

#pragma mark - 添加定时器显示时间和进度条
- (NSTimer *)addMusicTimer {
    return [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
}

- (void)timerRun {
    NSInteger currentTime = [[FFPlayer musicTool] currentTime];
    self.nowTimeLabel.text = [NSString stringWithFormat:@"%@",[self changeTimeToStr:currentTime]];
    NSInteger totalTime = [[FFPlayer musicTool] totalTime];
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%@",[self changeTimeToStr:totalTime]];
    //slider显示
    self.sliderProgress.value = [[FFPlayer musicTool] progress];
    // 计算缓冲进度
    NSTimeInterval timeInterval = [self availableDuration];
    CMTime duration             = [FFPlayer musicTool].songItem.duration;
    CGFloat totalDuration       = CMTimeGetSeconds(duration);
    [self.playerProgress setProgress:timeInterval / totalDuration animated:NO];
    
    if (self.sliderProgress.value >= 0.9999) {
        [self nextButtonAction:self.nextButton];
    }
    
//    if (currentTime % 10 == 0) {
//        [self revolveImageBeginRotate];
//    }
    
}

//转换时间的显示格式
- (NSString *)changeTimeToStr:(NSInteger)time {
    NSInteger second = time % 60;
    NSInteger minute = time / 60;
    NSString *showTime = [NSString stringWithFormat:@"%02ld:%02ld",minute,second];
    return showTime;
}

//计算缓冲进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[FFPlayer musicTool].songItem loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 创建视图
//图片旋转功能
- (void)createLayer {
    CALayer *layer = [CALayer layer];
    self.layer = layer;
    [self.revolveImage.layer addSublayer:layer];
    //设置layer属性
    layer.frame = CGRectMake(0, 0, 235, 235);
//    layer.frame = self.revolveImage.frame;
//    layer.contents = (id)[UIImage imageNamed:@"subscribe_albumDetail_order"].CGImage;
    layer.contents = (id)self.revolveImage.image.CGImage;
}

//创建视图
- (void)createView{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [ self.view addSubview:_backButton];
        [_backButton setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_revolveImage) {
        _revolveImage = [[UIImageView alloc] init];
        [_revolveImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
        _revolveImage.contentMode =  UIViewContentModeScaleAspectFill;
        _revolveImage.clipsToBounds  = YES;
        _revolveImage.layer.cornerRadius = 117.5;
        _revolveImage.layer.masksToBounds = YES;
        [self.view addSubview:_revolveImage];
    }
    if (!_nowTimeLabel) {
        _nowTimeLabel = [[UILabel alloc] init];
        _nowTimeLabel.text = @"00:00";
        _nowTimeLabel.textColor = [UIColor whiteColor];
        _nowTimeLabel.textAlignment = NSTextAlignmentCenter;
        _nowTimeLabel.font = [UIFont systemFontOfSize:11];
        [self.view addSubview:_nowTimeLabel];
    }
    if (!_playerProgress) {
        _playerProgress = [[UIProgressView alloc] init];
        //更改进度条高度
        _playerProgress.transform = CGAffineTransformMakeScale(1.0f,1.0f);
        _playerProgress.tintColor = [UIColor blackColor];
        [self.view addSubview:_playerProgress];
    }
    if (!_sliderProgress) {
        _sliderProgress = [[UISlider alloc] init];
        _sliderProgress.value = 0.f;
        _sliderProgress.continuous = YES;
        _sliderProgress.tintColor = [UIColor orangeColor];
        _sliderProgress.maximumTrackTintColor = [UIColor clearColor];
        [self.view addSubview:_sliderProgress];
        [_sliderProgress setThumbImage:[UIImage imageNamed:@"sliderBall"] forState:UIControlStateNormal];
        [_sliderProgress addTarget:self action:@selector(durationSliderTouch:) forControlEvents:UIControlEventValueChanged];
        [_sliderProgress addTarget:self action:@selector(durationSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.font = [UIFont systemFontOfSize:11];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_totalTimeLabel];
    }
    if (!_musicTitleLabel) {
        _musicTitleLabel = [[UILabel alloc] init];
        _musicTitleLabel.font = [UIFont systemFontOfSize:15];
        _musicTitleLabel.text = @"青岛DJ皇阿玛";
        _musicTitleLabel.textColor = [UIColor whiteColor];
        _musicTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_musicTitleLabel];
    }
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.selected = YES;
        [ self.view addSubview:_playButton];
        [_playButton setBackgroundImage:[UIImage imageNamed:@"startBtn_p"] forState:UIControlStateNormal];
        [_playButton setBackgroundImage:[UIImage imageNamed:@"startBtn_s"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!_lastButton) {
        _lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_lastButton];
        [_lastButton addTarget:self action:@selector(lastButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_lastButton setImage:[UIImage imageNamed:@"startBtn_left"] forState:UIControlStateNormal];
    }
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_nextButton];
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_nextButton setImage:[UIImage imageNamed:@"startBtn_right"] forState:UIControlStateNormal];
    }
    [self viewsLocation];
}

- (void)viewsLocation{
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(20);
        make.width.height.mas_equalTo(40);
    }];
    [self.revolveImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo (60);
        make.width.height.mas_equalTo(235);
    }];
    [self.nowTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.revolveImage.mas_bottom).offset(40);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(10);
    }];
    [self.playerProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nowTimeLabel.mas_right).offset(0);
        make.centerY.mas_equalTo(self.nowTimeLabel.mas_centerY);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width - 130);
        make.height.mas_equalTo(2);
    }];
    [self.sliderProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nowTimeLabel.mas_right).offset(0);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width - 130);
        make.top.mas_equalTo(self.playerProgress.mas_top).offset(-10);
        make.height.mas_equalTo(20);
    }];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sliderProgress.mas_right).offset(0);
        make.top.mas_equalTo(self.revolveImage.mas_bottom).offset(40);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(10);
    }];
    [self.musicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.totalTimeLabel.mas_bottom).offset(20);
    }];
    [self.lastButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(100);
        make.top.mas_equalTo(self.totalTimeLabel.mas_bottom).offset(90);
        make.width.height.mas_equalTo(40);
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-100);
        make.top.mas_equalTo(self.totalTimeLabel.mas_bottom).offset(90);
        make.width.height.mas_equalTo(40);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.lastButton.mas_centerY);
        make.width.height.mas_equalTo(60);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - 播放点击事件
- (void)playAction:(UIButton *)btn {
    if (btn.selected) {
        [[FFPlayer musicTool] pause];
    }else {
        [[FFPlayer musicTool] play];
    }
    btn.selected = !btn.selected;
}

- (void)lastButtonAction:(UIButton *)btn {
    self.currentIndex--;
    [self startPlay];
}

- (void)nextButtonAction:(UIButton *)btn {
    self.currentIndex++;
    [self startPlay];
}

- (void)startPlay {
//    self.animation = nil;
    NSDictionary *musicDic = self.musicArr[self.currentIndex];
//    [_revolveImage sd_setImageWithURL:[NSURL URLWithString:musicDic[@"coverMiddle"]]];
    [_revolveImage sd_setImageWithURL:[NSURL URLWithString:musicDic[@"coverMiddle"]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self createLayer];
        self.revolveImage.image = nil;
        [self revolveImageBeginRotate];
    }];
    _musicTitleLabel.text = musicDic[@"title"];
    
    if ([FFPlayer musicTool].isPlaying && [[FFPlayer musicTool].musicUrl isEqualToString:musicDic[@"playUrl64"]]) {
        [[FFPlayer musicTool] play];
    }else {
        [[FFPlayer musicTool] playWithMusicName:musicDic[@"playUrl64"]];
    }
    self.timer = [self addMusicTimer];
}

- (void)durationSliderTouch:(UISlider *)slider {
    NSInteger totalTime = [[FFPlayer musicTool] totalTime];
    NSInteger seekTime = slider.value * totalTime;
    CMTime seekToTime = CMTimeMakeWithSeconds(seekTime,1);
    [[FFPlayer musicTool].avPlayer seekToTime:seekToTime];
    
}
- (void)durationSliderTouchEnded:(UISlider *)slider {
    if (slider.value == 1) {
        [self nextButtonAction:self.nextButton];
    }
    
}

- (void)backBtnAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - 视图旋转功能
//点击旋转按钮的方法
- (void)revolveImageBeginRotate {
    [self makeBasicAnimation:@"transform.rotation" value:@(2*M_PI) valueType:@"by"];
}
- (void)makeBasicAnimation:(NSString *)keyPath value:(id)value valueType:(NSString *)type{
    //创建基本动画，以及动画的属性
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    self.animation = animation;
    //先慢后快
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    //匀速转动
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    //设置动画属性的值
    if ([type isEqualToString:@"to"]) {
        animation.toValue = value;
    }else if([type isEqualToString:@"by"]){
        animation.byValue = value;
    }
    //设置动画时间
    animation.duration = 20;
    animation.repeatCount = HUGE_VALF;
    //动画终了后不返回初始状态
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    //将动画加入到layer中
    [self.layer addAnimation:animation forKey:nil];
    
    [self performSelector:@selector(animationEnd) withObject:nil afterDelay:1];
    
}
//动画结束的方法 (获取逆序数据)
- (void)animationEnd {
    
}



@end
