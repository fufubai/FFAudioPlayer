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
#import <SDWebImage.h>
#import "FFPlayViewViewController.h"
#import "FFDownloadListViewController.h"
#import "FFCustomDownloadingViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic,strong)FFPlayViewViewController *playerViewVC;

@property (nonatomic,strong)UIImageView *liveImage;//动画图片
@end

static NSString *MUSICURL = @"http://mobile.ximalaya.com/mobile/v1/album?albumId=3021864&device=iPhone&pageSize=20&source=5&statEvent=pageview%2Falbum%403021864&statModule=听小说_幻想&statPage=categorytag%40听小说_幻想&statPosition=105";
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
    [self prepareDownloadBtnlist];
}

- (void)loadData {
    [FFNetWorkTool doGetWithURLString:[MUSICURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] params:nil success:^(id  _Nonnull response) {
        for (NSDictionary *dic in response[@"data"][@"tracks"][@"list"]) {
            [self.dataArray addObject:dic];
        }
        [self prepareFooterView];
        [self.tableView reloadData];
    }];
    
}

- (void)prepareTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
- (void)prepareFooterView {
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadBtn addTarget:self action:@selector(downloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [downloadBtn setTitle:@"批量下载" forState:UIControlStateNormal];
    downloadBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    downloadBtn.layer.borderColor = [UIColor blackColor].CGColor;
    downloadBtn.layer.borderWidth = 1;
    downloadBtn.layer.cornerRadius = 10;
    downloadBtn.clipsToBounds = YES;
    [tableFooterView addSubview:downloadBtn];
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tableFooterView.mas_centerX);
        make.centerY.equalTo(tableFooterView.mas_centerY);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(30);
    }];
    self.tableView.tableFooterView = tableFooterView;
}
- (void)downloadBtnClick:(UIButton *)btn {
    FFCustomDownloadingViewController *customDownloadingVC = [[FFCustomDownloadingViewController alloc] init];
    customDownloadingVC.musicArr = self.dataArray;
    [self.navigationController pushViewController:customDownloadingVC animated:YES];
}

#pragma mark - 右上角进入下载界面的按钮
- (void)prepareDownloadBtnlist {
    UIButton *downloadListBtn = [UIButton buttonWithType:UIButtonTypeCustom];;
    downloadListBtn.bounds = CGRectMake(0, 0, 80, 30);
    [downloadListBtn setImage:[UIImage imageNamed:@"startBtn_right"] forState:UIControlStateNormal];
    [downloadListBtn setTitle:@"已下载" forState:UIControlStateNormal];
    downloadListBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [downloadListBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [downloadListBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:downloadListBtn];
    [downloadListBtn addTarget:self action:@selector(downloadListBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonWordAndImageWithButton:downloadListBtn];
}

//设置左文字右图片
- (void)setButtonWordAndImageWithButton:(UIButton *)downloadListBtn {
    [downloadListBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -downloadListBtn.imageView.bounds.size.width, 0, downloadListBtn.imageView.bounds.size.width)];
    [downloadListBtn setImageEdgeInsets:UIEdgeInsetsMake(0, downloadListBtn.titleLabel.bounds.size.width, 0, -downloadListBtn.titleLabel.bounds.size.width)];
}

//下载列表按钮点击方法
- (void)downloadListBtnClick:(UIButton *)btn {
    FFDownloadListViewController *downloadListVC = [[FFDownloadListViewController alloc] init];
    [self.navigationController pushViewController:downloadListVC animated:YES];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.textLabel.text = dic[@"title"];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self presentToPlayVC:indexPath.row];
}



#pragma mark - 添加声浪动画
- (void)addVoiceAnimation {
    self.liveImage.hidden = NO;
    self.navigationItem.titleView = nil;
    self.liveImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_live_image0"]];
    NSArray *gifArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"audio_live_image0"],[UIImage imageNamed:@"audio_live_image1"],[UIImage imageNamed:@"audio_live_image2"],[UIImage imageNamed:@"audio_live_image3"],[UIImage imageNamed:@"audio_live_image4"], nil];
    self.liveImage.animationImages = gifArray;
    self.liveImage.animationRepeatCount = 0;
    self.liveImage.animationDuration = 0.5;
    [self.liveImage startAnimating];
    
    self.liveImage.frame = CGRectMake(0, 0, 20, 20);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.liveImage];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPlayVC:)];
    [self.liveImage addGestureRecognizer:tap];
    if (self.liveImage.animating) {
        self.liveImage.userInteractionEnabled = YES;
    }else {
        self.liveImage.userInteractionEnabled = NO;
    }
    
}

- (void)gotoPlayVC:(UITapGestureRecognizer *)tap {
    [self presentToPlayVC:self.playerViewVC.currentIndex];
}

- (void)presentToPlayVC:(NSInteger)index {
    FFPlayViewViewController *playerViewVC = [[FFPlayViewViewController alloc] init];
    self.playerViewVC = playerViewVC;
    playerViewVC.musicArr = self.dataArray;
    playerViewVC.currentIndex = index;
    playerViewVC.isLocal = NO;
    __weak typeof(self) weakSelf = self;
    [playerViewVC setMusicIsPlaying:^(BOOL isPlaying) {
        if (isPlaying) {
            [self addVoiceAnimation];
        }else {
//            [weakSelf.liveImage stopAnimating];
            weakSelf.liveImage.hidden = YES;
        }
    }];
    [self presentViewController:playerViewVC animated:YES completion:nil];
}



@end
