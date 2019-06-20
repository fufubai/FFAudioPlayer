//
//  ViewController.m
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/17/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import "ViewController.h"
#import "PrefixHeader.pch"
#import <AFNetworking.h>
#import "FFNetWorkTool.h"
#import <Masonry.h>
#import "FFPlayViewViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic,strong)UIImageView *liveImage;//动画图片
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
    [self loadData];
    self.title = @"FFAudioPlayer";
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self prepareTableView];
}

- (void)loadData {
    NSString *url = @"http://mobile.ximalaya.com/mobile/v1/album?albumId=3021864&device=iPhone&pageSize=20&source=5&statEvent=pageview%2Falbum%403021864&statModule=听小说_幻想&statPage=categorytag%40听小说_幻想&statPosition=105";
    [FFNetWorkTool doGetWithURLString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] params:nil success:^(id  _Nonnull response) {
        for (NSDictionary *dic in response[@"data"][@"tracks"][@"list"]) {
            [self.dataArray addObject:dic];
        }
        [self.tableView reloadData];
    }];
    
}

- (void)prepareTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - tableView 代理方法和数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuse = @"cellReuse";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
    }
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.textLabel.text = dic[@"title"];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FFPlayViewViewController *playerViewVC = [[FFPlayViewViewController alloc] init];
    playerViewVC.musicArr = self.dataArray;
    playerViewVC.currentIndex = indexPath.row;
    [playerViewVC setMusicIsPlaying:^(BOOL isPlaying) {
        if (isPlaying) {
            [self addVoiceAnimation];
        }else {
            [self.liveImage stopAnimating];
        }
    }];
    [self presentViewController:playerViewVC animated:YES completion:nil];
}

#pragma mark - 添加声浪动画
- (void)addVoiceAnimation {
    self.navigationItem.titleView = nil;
    self.liveImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_live_image0"]];
    NSArray *gifArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"audio_live_image0"],[UIImage imageNamed:@"audio_live_image1"],[UIImage imageNamed:@"audio_live_image2"],[UIImage imageNamed:@"audio_live_image3"],[UIImage imageNamed:@"audio_live_image4"], nil];
    self.liveImage.animationImages = gifArray;
    self.liveImage.animationRepeatCount = 0;
    self.liveImage.animationDuration = 0.5;
    [self.liveImage startAnimating];
    
    self.liveImage.frame = CGRectMake(0, 0, 20, 20);
    self.navigationItem.titleView = self.liveImage;
}


@end
