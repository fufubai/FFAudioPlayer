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
#import "FFNetWorkTool.h"
#import "PrefixHeader.pch"
#import <MediaPlayer/MediaPlayer.h>//后台播放

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
@property (nonatomic, strong) UIButton *downloadButton;//下载按钮
@property (nonatomic, strong) UIButton *stopDownloadButton;//暂停下载
@property (nonatomic,strong)NSURLSessionDownloadTask *downloadTask;

@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)CALayer *layer;//图片旋转功能
@property (nonatomic,strong)CABasicAnimation *animation;

@property (nonatomic,strong)NSDictionary *musicDic;//音频数据
@property (nonatomic,strong)NSMutableArray *musicMArr;//保存本地音频数据

@property (nonatomic,strong)UIImage *saveImage;
@end

@implementation FFPlayViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    [self createView];
    FFLog(@"走了吗");
    [self addDownSwipeGesture];
    [self startPlay];
    [self createMutableAudioArray];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishDownloadMusic:) name:@"MusicDownloadedNotification" object:nil];
    
    //设置后台播放  锁屏功能展示图片
    //1.让当前控制器作为第一响应者
    [self becomeFirstResponder];
    //2.开启接收远程 事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
}
- (void)finishDownloadMusic:(NSNotification *)noti {
    if ([noti.object isEqualToString:self.musicDic[MUSIC_WEB]]) {
        self.downloadButton.selected = NO;
        self.downloadButton.enabled = NO;
        self.stopDownloadButton.hidden = YES;
    }
    
}

//创建一个存放音频数据的数组
- (void)createMutableAudioArray {
    if (!self.musicMArr) {
        NSMutableArray *musicMArr = [NSMutableArray array];
        self.musicMArr = musicMArr;
        //获取NSUserDefaults对象
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //保存数据
        [defaults setObject:musicMArr forKey:@"audioNameArray"];
        //同步数据
        [defaults synchronize];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.isLocal) {
        self.downloadButton.hidden = YES;
        self.stopDownloadButton.hidden = YES;
    }else {
        NSDictionary *dict = self.musicArr[self.currentIndex];
        //1、查询是否已经下载
        NSDictionary *downloadDict = [FFSQLiteTool queryDownloadMusicWithTitleName:dict[MUSICTITLE_WEB]];
        if ([downloadDict[@"isExist"] boolValue]) {
            self.downloadButton.selected = NO;
            self.downloadButton.enabled = NO;
            self.stopDownloadButton.hidden = YES;
        }else {
            self.downloadButton.selected = NO;
            self.downloadButton.enabled = YES;
        }
        //2、查询是否在下载队列中
        if ([[FFNetWorkTool shareNetWorkTool].downloadingUrlArray containsObject:dict[MUSIC_WEB]]) {
            self.downloadButton.selected = YES;
        }else {
            self.downloadButton.selected = NO;
        }
    }
}

#pragma mark - 创建视图
- (void)createView{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [ self.view addSubview:_backButton];
        [_backButton setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!self.downloadButton) {
        self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:self.downloadButton];
        [self.downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.downloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        [self.downloadButton setImage:[UIImage imageNamed:@"downloading"] forState:UIControlStateSelected];
        [self.downloadButton setImage:[UIImage imageNamed:@"downloaded"] forState:UIControlStateDisabled];
        self.downloadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;//图片右对齐
        
        [self.downloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        self.downloadButton.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    if (!self.stopDownloadButton) {
        self.stopDownloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:self.stopDownloadButton];
        [self.stopDownloadButton addTarget:self action:@selector(stopDownloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.stopDownloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.stopDownloadButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        self.stopDownloadButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.stopDownloadButton setTitle:@"暂停下载" forState:UIControlStateNormal];
        [self.stopDownloadButton setTitle:@"继续" forState:UIControlStateSelected];
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
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(40);
    }];
    [self.stopDownloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.downloadButton.mas_bottom).mas_offset(10);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
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

#pragma mark - 为界面添加向下滑动手势
- (void)addDownSwipeGesture {
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [[self view] addGestureRecognizer:recognizer];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 播放点击事件
- (void)playAction:(UIButton *)btn {
    if (btn.selected) {
        [[FFPlayer musicTool] pause];
        [self removeMusicTimer];
        self.musicIsPlaying(NO);
        [self animationPause];
    }else {
        [[FFPlayer musicTool] play];
        [self animationContinue];
    }
    btn.selected = !btn.selected;
}

- (void)lastButtonAction:(UIButton *)btn {
    self.currentIndex--;
    if (self.currentIndex >= self.musicArr.count) {
        self.currentIndex = 0;
    }
    [self startPlay];
    if (self.layer.speed == 0) {
        [self animationContinue];
    }
}

- (void)nextButtonAction:(UIButton *)btn {
    self.currentIndex++;
    if (self.currentIndex >= self.musicArr.count) {
        self.currentIndex = 0;
    }
    [self startPlay];
    if (self.layer.speed == 0) {
        [self animationContinue];
    }
}

- (void)startPlay {
    self.playButton.selected = YES;
    NSDictionary *musicDic = [NSDictionary dictionary];
    NSString *picUrl;
    FFWeakSelf;
    
    if (self.isLocal) {
        musicDic = self.musicArr[self.currentIndex];
        picUrl = [musicDic objectForKey:@"musicUrl"];
        
        _revolveImage.image = [UIImage imageWithData:[musicDic objectForKey:@"picData"] ];
        NSData *musicData = [musicDic objectForKey:@"musicData"];
        [FFPlayer musicTool].isLocal = YES;
        _musicTitleLabel.text = musicDic[LOCAL_TITLENAME];
        if ([[FFPlayer musicTool].musicUrl isEqualToString:[musicDic objectForKey:@"musicUrl"]]) {
            [[FFPlayer musicTool] play];
        }else {
            [[FFPlayer musicTool] playLocalMusic:musicData];
        }
        [FFPlayer musicTool].musicUrl = [musicDic objectForKey:@"musicUrl"];
        [self addAnimationOfPic];
    }else {
        musicDic = self.musicArr[self.currentIndex];
        //查询是否已下载
        NSDictionary *dict = [FFSQLiteTool queryDownloadMusicWithTitleName:musicDic[MUSICTITLE_WEB]];
        if ([dict[@"isExist"] boolValue]) {//1已下载
            _revolveImage.image = [UIImage imageWithData:[dict objectForKey:@"picData"] ];
            NSData *musicData = [dict objectForKey:@"musicData"];
            [FFPlayer musicTool].isLocal = YES;
            _musicTitleLabel.text = dict[LOCAL_TITLENAME];
            if ([[FFPlayer musicTool].musicUrl isEqualToString:[dict objectForKey:@"musicUrl"]]) {
                [[FFPlayer musicTool] play];
            }else {
                [[FFPlayer musicTool] playLocalMusic:musicData];
            }
            [FFPlayer musicTool].musicUrl = [dict objectForKey:@"musicUrl"];
            [self addAnimationOfPic];
        }else {//2未下载
            picUrl = musicDic[COVERMIDDLE_WEB];
            NSString *stringPath = musicDic[MUSIC_WEB];
            [_revolveImage sd_setImageWithURL:[NSURL URLWithString:picUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                weakSelf.saveImage = image;
                [self addAnimationOfPic];
            }];
            _musicTitleLabel.text = musicDic[MUSICTITLE_WEB];
            if ([[FFPlayer musicTool].musicUrl isEqualToString:stringPath]) {
                [[FFPlayer musicTool] play];
            }else {
                [[FFPlayer musicTool] playWithMusicUrl:stringPath];
            }
            [FFPlayer musicTool].isLocal = NO;
        }
        
    }
    
    self.musicDic = musicDic;
    
    self.musicIsPlaying(YES);
    self.timer = [self addMusicTimer];
}

//图片旋转动画
- (void)addAnimationOfPic {
    [self createLayer];
    [self revolveImageBeginRotate];
}

//拖动slider
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

#pragma mark - 下载功能（储存到沙盒documents）
- (void)downloadButtonAction:(UIButton *)btn {
    btn.selected = YES;
    __block NSString *downloadUrl = self.musicDic[MUSIC_WEB];
    [btn setImage:nil forState:UIControlStateNormal];
    //查询是否已经下载
    NSDictionary *downloadDict = [FFSQLiteTool queryDownloadMusicWithTitleName:self.musicDic[MUSICTITLE_WEB]];
    if (![downloadDict[@"isExist"] boolValue]) {
        [[FFNetWorkTool shareNetWorkTool].downloadingUrlArray addObject:downloadUrl];
        NSURLSessionDownloadTask *downloadTask = [FFNetWorkTool DownloadAudioWithUrlString:downloadUrl params:nil progress:^(NSProgress * _Nonnull progress) {
            FFLog(@"progress_____%f__%@__%lld__%lld___downloadUrl=%@",progress.fractionCompleted,progress.localizedDescription,progress.completedUnitCount,progress.totalUnitCount,downloadUrl);
            if ([self.musicDic[MUSIC_WEB] isEqualToString:downloadUrl]) {
                [self performSelectorOnMainThread:@selector(setDownloadBtnTitle:) withObject:progress waitUntilDone:YES];
            }
        } success:^(id  _Nonnull response) {
            NSDictionary *dict = @{@"response":response,@"downloadUrl":downloadUrl};
            [self performSelectorOnMainThread:@selector(saveMusicData:) withObject:dict waitUntilDone:nil];
        }];
        self.downloadTask = downloadTask;

        
    }else {
        FFLog(@"已下载");
    }
    
    
}

- (void)setDownloadBtnTitle:(NSProgress *)progress {
    [self.downloadButton setImage:nil forState:UIControlStateNormal];
    NSRange range = [progress.localizedDescription rangeOfString:@"%"];
    NSString *rate = [progress.localizedDescription substringToIndex:range.location+1];
    [self.downloadButton setTitle:[NSString stringWithFormat:@"%@",rate] forState:UIControlStateSelected];
}

//下载完毕存储音频
- (void)saveMusicData:(NSDictionary *)dict {
    self.downloadButton.selected = NO;
    self.downloadButton.enabled = NO;
    NSData *musicData =[NSData dataWithContentsOfFile:dict[@"response"]];
    NSData *imageData = UIImageJPEGRepresentation(self.saveImage,1.0f);//第二个参数为压缩倍数
    [FFSQLiteTool addDownloadMusicWithTitleName:self.musicDic[MUSICTITLE_WEB] musicUrl:self.musicDic[MUSIC_WEB] pictureData:imageData musicData:musicData];
    //必须发送通知到viewdidload里面刷新按钮的状态
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MusicDownloadedNotification" object:dict[@"downloadUrl"]];
    [[FFNetWorkTool shareNetWorkTool].downloadingUrlArray removeObject:dict[@"downloadUrl"]];
}

//暂停
- (void)stopDownloadButtonAction:(UIButton *)btn {
    if (btn.selected) {
        [self.downloadTask resume];
    }else {
        [self.downloadTask suspend];
    }
    btn.selected = !btn.selected;
}

#pragma mark - 添加定时器显示时间和进度条
- (NSTimer *)addMusicTimer {
    return [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
}

- (void)removeMusicTimer {
    [self.timer invalidate];
    self.timer = nil;
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
    
    [self backgroundPlayingFunc];//后台播放
    
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

- (void)dealloc {
    [self removeMusicTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 视图旋转功能
- (void)createLayer {
    if (!self.layer) {
        CALayer *layer = [CALayer layer];
        self.layer = layer;
        [self.revolveImage.layer addSublayer:layer];
        //设置layer属性
        layer.frame = CGRectMake(0, 0, 235, 235);
        layer.contents = (id)self.revolveImage.image.CGImage;
    }
}
//点击旋转按钮的方法
- (void)revolveImageBeginRotate {
    if (!self.animation) {
        [self makeBasicAnimation:@"transform.rotation" value:@(2*M_PI) valueType:@"by"];
    }
}
- (void)makeBasicAnimation:(NSString *)keyPath value:(id)value valueType:(NSString *)type{
    //创建基本动画，以及动画的属性
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    self.animation = animation;
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

//暂停动画
- (void)animationPause {
    // 当前时间（暂停时的时间）
    // CACurrentMediaTime() 是基于内建时钟的，能够更精确更原子化地测量，并且不会因为外部时间变化而变化（例如时区变化、夏时制、秒突变等）,但它和系统的uptime有关,系统重启后CACurrentMediaTime()会被重置
    CFTimeInterval pauseTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 停止动画
    self.layer.speed = 0;
    // 动画的位置（动画进行到当前时间所在的位置，如timeOffset=1表示动画进行1秒时的位置）
    self.layer.timeOffset = pauseTime;
}
//继续动画
- (void)animationContinue {
    // 动画的暂停时间
    CFTimeInterval pausedTime = self.layer.timeOffset;
    // 动画初始化
    self.layer.speed = 1;
    self.layer.timeOffset = 0;
    self.layer.beginTime = 0;
    // 程序到这里，动画就能继续进行了，但不是连贯的，而是动画在背后默默“偷跑”的位置，如果超过一个动画周期，则是初始位置
    // 当前时间（恢复时的时间）
    CFTimeInterval continueTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 暂停到恢复之间的空档
    CFTimeInterval timePause = continueTime - pausedTime;
    // 动画从timePause的位置从动画头开始
    self.layer.beginTime = timePause;
}


#pragma mark - 后台播放
//更新锁屏界面的信息
- (void)backgroundPlayingFunc
{
    //正在播放的信息中心
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //当前时间  总时间  图片  歌词 专辑名称 歌手名称
    NSDictionary *musicDic = [NSDictionary dictionary];
    musicDic = self.musicArr[self.currentIndex];
    
    
    
    dict[MPMediaItemPropertyPlaybackDuration] = @([[FFPlayer musicTool]totalTime]);
    dict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @([[FFPlayer musicTool] currentTime]);
    //    dict[MPMediaItemPropertyArtist] = music.singer;//歌手
    //    dict[MPMediaItemPropertyAlbumTitle]  = music.zhuanji;//专辑
    
    dict[MPMediaItemPropertyTitle] = musicDic[MUSICTITLE_WEB];
    
    
    //1.绘制正方形的图片
    UIImage *rectImage = self.revolveImage.image;
    
    CGRect rect  = CGRectMake(0, 0, 200, 200);
    //设备上下文
    UIGraphicsBeginImageContext(rect.size);
    [rectImage drawInRect:rect];
    
    //2.显示锁屏歌词 (绘制歌词语句到专辑图片上)
    //拿到歌词
    
    //    CZLrcModel *lrc = self.allLrcs[_currentIndexForLrc];
    
    //    [lrc.text drawInRect:CGRectMake(0, rect.size.height - 64, rect.size.width, 44) withFont:[UIFont systemFontOfSize:22] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    //绘制上去
    
    //设置图片
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    //关闭设备上下文
    UIGraphicsEndImageContext();
    
    
    
//    dict[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc]initWithImage:result];
    dict[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithBoundsSize:rect.size requestHandler:^UIImage * _Nonnull(CGSize size) {
        return result;
    }];
    
    //播放中心
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = dict;
}
//3.接收到事件之后做处理
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    /*
     UIEventSubtypeRemoteControlPlay                 = 100,播放
     UIEventSubtypeRemoteControlPause                = 101,暂停
     UIEventSubtypeRemoteControlStop                 = 102,停止
     UIEventSubtypeRemoteControlTogglePlayPause      = 103,耳机
     UIEventSubtypeRemoteControlNextTrack            = 104,下一曲
     UIEventSubtypeRemoteControlPreviousTrack        = 105, 上一曲
     UIEventSubtypeRemoteControlBeginSeekingBackward = 106, 开始快退
     UIEventSubtypeRemoteControlEndSeekingBackward   = 107,结束快退
     UIEventSubtypeRemoteControlBeginSeekingForward  = 108, 开始快进
     UIEventSubtypeRemoteControlEndSeekingForward    = 109,结束快进
     */
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            [self startPlay];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self playAction:self.playButton];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self nextButtonAction:self.nextButton];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self lastButtonAction:self.lastButton];
            break;
        default:
            break;
    }
    
}
//让当前控制器 能够成为第一响应者(使得走第三步的方法)
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

//判断当前是否为后台播放
-(BOOL) runningInBackground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateBackground);
    
    return result;
}

@end
