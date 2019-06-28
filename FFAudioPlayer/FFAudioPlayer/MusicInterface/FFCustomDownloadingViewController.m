//
//  FFCustomDownloadingViewController.m
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/27/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import "FFCustomDownloadingViewController.h"
#import <AFNetworking.h>
#import "FFNetWorkTool.h"
//#import <SDWebImage.h>
#import <SDWebImageManager.h>
#import "PrefixHeader.pch"

@interface FFCustomDownloadingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *downloadArr;

@property (nonatomic,strong)UIButton *downloadListBtn;
@end

@implementation FFCustomDownloadingViewController

- (NSMutableArray *)downloadArr {
    if (!_downloadArr) {
        _downloadArr = [NSMutableArray arrayWithCapacity:20];
    }
    return _downloadArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"批量下载";
    [self prepareTableView];
    [self prepareDownloadBtnlist];
}
- (void)prepareDownloadBtnlist {
    UIButton *downloadListBtn = [UIButton buttonWithType:UIButtonTypeCustom];;
    self.downloadListBtn = downloadListBtn;
    downloadListBtn.bounds = CGRectMake(0, 0, 80, 30);
    [downloadListBtn setTitle:@"编辑下载" forState:UIControlStateNormal];
    [downloadListBtn setTitle:@"开始下载" forState:UIControlStateSelected];
    [downloadListBtn setTitle:@"正在下载" forState:UIControlStateDisabled];
    downloadListBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [downloadListBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [downloadListBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [downloadListBtn setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:downloadListBtn];
    [downloadListBtn addTarget:self action:@selector(downloadListBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)downloadListBtnClick:(UIButton *)btn {
    if (btn.selected) {
        if (self.downloadArr.count > 0) {
            btn.selected = NO;
            btn.enabled = NO;
            [self downloadSelectedMusic];
        }else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择要下载的音频" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"下载方式" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"全部下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.tableView setEditing:YES animated:YES];
            [self downloadAll];
            self.downloadListBtn.selected = YES;
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"批量下载" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.tableView setEditing:YES animated:YES];
            self.downloadListBtn.selected = YES;
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

//删除全部
- (void)downloadAll {
    for (int i = 0; i < self.musicArr.count; i ++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        NSDictionary *dict = self.musicArr[i];
        if ([[FFSQLiteTool queryDownloadMusicWithTitleName:dict[MUSICTITLE_WEB]][@"isExist"] boolValue]) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.backgroundColor = [UIColor redColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            [self.downloadArr addObject:self.musicArr[i]];
        }
        
    }
}

#pragma mark - tableView
- (void)prepareTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    [self.view addSubview:self.tableView];
    self.tableView.allowsSelection = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.musicArr[indexPath.row];
    if ([[FFSQLiteTool queryDownloadMusicWithTitleName:dict[MUSICTITLE_WEB]][@"isExist"] boolValue]) {
        return NO;
    }else {
        return YES;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musicArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuse = @"cellReuse";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse];
    }
    NSDictionary *dic = self.musicArr[indexPath.row];
    cell.textLabel.text = dic[MUSICTITLE_WEB];
    if ([[FFSQLiteTool queryDownloadMusicWithTitleName:dic[MUSICTITLE_WEB]][@"isExist"] boolValue]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",@"100%"];
        cell.backgroundColor = [UIColor redColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",@"0%"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.musicArr[indexPath.row];
    if (![[FFSQLiteTool queryDownloadMusicWithTitleName:dic[MUSICTITLE_WEB]][@"isExist"] boolValue]) {
        [self.downloadArr addObject:self.musicArr[indexPath.row]];
        FFLog(@"self.downloadArr.count%ld",self.downloadArr.count);
    }
    
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.downloadArr removeObject:self.musicArr[indexPath.row]];
    FFLog(@"%ld",self.downloadArr.count);
}

#pragma mark - 批量下载方法
- (void)downloadSelectedMusic {
    self.tableView.allowsSelection = NO;
    for (int i = 0;i<self.downloadArr.count ;i++) {
        __block NSDictionary *dict = self.downloadArr[i];
        __block NSString *downloadUrl = dict[MUSIC_WEB];
        [[FFNetWorkTool shareNetWorkTool].downloadingUrlArray addObject:downloadUrl];
        [FFNetWorkTool DownloadAudioWithUrlString:downloadUrl params:nil progress:^(NSProgress * _Nonnull progress) {
            FFLog(@"progress_____%f__%@__%lld__%lld___downloadUrl=%@",progress.fractionCompleted,progress.localizedDescription,progress.completedUnitCount,progress.totalUnitCount,downloadUrl);
            NSDictionary *dict1 = @{@"progress":progress,@"downloadUrl":downloadUrl};
            [self performSelectorOnMainThread:@selector(setDownloadBtnTitle:) withObject:dict1 waitUntilDone:YES];
        } success:^(id  _Nonnull response) {
            NSDictionary *dict2 = @{@"response":response,@"downloadUrl":downloadUrl,LOCAL_TITLENAME:dict[MUSICTITLE_WEB],@"coverImageUrl":dict[COVERMIDDLE_WEB]};
            [self performSelectorOnMainThread:@selector(saveMusicData:) withObject:dict2 waitUntilDone:nil];
        }];
    }
    
}

- (void)setDownloadBtnTitle:(NSDictionary *)dict {
    for (int i = 0; i < self.musicArr.count; i ++ ) {
        NSDictionary *dictAll = self.musicArr[i];
        if ([dictAll[MUSIC_WEB] isEqualToString:dict[@"downloadUrl"]]) {
            NSProgress *progress = dict[@"progress"];
            NSRange range = [progress.localizedDescription rangeOfString:@"%"];
            NSString *rate = [progress.localizedDescription substringToIndex:range.location + 1];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.backgroundColor = [UIColor redColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.text = rate;
            
        }
    }
}

//下载完毕存储音频
- (void)saveMusicData:(NSDictionary *)dict {
    __block NSData *musicData =[NSData dataWithContentsOfFile:dict[@"response"]];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:dict[@"coverImageUrl"] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        [FFSQLiteTool addDownloadMusicWithTitleName:dict[LOCAL_TITLENAME] musicUrl:dict[@"downloadUrl"] pictureData:data musicData:musicData];
        [[FFNetWorkTool shareNetWorkTool].downloadingUrlArray removeObject:dict[@"downloadUrl"]];
        [self performSelectorOnMainThread:@selector(downloadedChangeUI:) withObject:dict[LOCAL_TITLENAME] waitUntilDone:NO];
    }];
    
    
    
}

- (void)downloadedChangeUI:(NSString *)titleName {
    for (int i = 0; i<self.downloadArr.count; i++) {
        NSDictionary *dict = self.downloadArr[i];
        if ([dict[MUSICTITLE_WEB] isEqualToString:titleName]) {
            [self.downloadArr removeObjectAtIndex:i];
        }
    }
    if (self.downloadArr.count == 0) {
        self.downloadListBtn.enabled = YES;
        self.downloadListBtn.selected = NO;
        sleep(1);//防止查询和写入不匹配
        [self.tableView reloadData];
    }
    
}

@end
