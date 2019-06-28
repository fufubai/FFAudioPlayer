//
//  FFDownloadListViewController.m
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/20/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import "FFDownloadListViewController.h"
#import "FFPlayViewViewController.h"
#import "PrefixHeader.pch"
#import "FFPlayer.h"

@interface FFDownloadListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;

@property (nonatomic,strong)FFPlayViewViewController *playerViewVC;

@end

@implementation FFDownloadListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"download list";
    [self prepareTableView];
    [self getDownloadUrl];
    [self prepareDownloadBtnlist];
}

#pragma mark - 右上角批量删除按钮
- (void)prepareDownloadBtnlist {
    UIButton *deleteAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];;
    deleteAllBtn.bounds = CGRectMake(0, 0, 80, 30);
    [deleteAllBtn setTitle:@"全部删除" forState:UIControlStateNormal];
    deleteAllBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [deleteAllBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [deleteAllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteAllBtn];
    [deleteAllBtn addTarget:self action:@selector(deleteAllBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)deleteAllBtnClick:(UIButton *)btn {
    UIAlertController *alertController;
    if (self.dataArray.count <= 0) {
        return;
    }
    [self getDownloadUrl];
    alertController = [UIAlertController alertControllerWithTitle:@"确认删除" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([FFSQLiteTool deleteAllDownloadMusic]){
            [self getDownloadUrl];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
        
}

//准备tableview
- (void)prepareTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

//从沙盒获取下载文件
- (void)getDownloadUrl {
    self.dataArray = [FFSQLiteTool queryAllDownloadMusic].mutableCopy;
    [self.tableView reloadData];
    [self setExtraCellLineHidden:self.tableView];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse];
    }
    
    NSMutableDictionary *dic = self.dataArray[indexPath.row];
    cell.textLabel.text = dic[LOCAL_TITLENAME];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self presentToPlayVC:indexPath.row];
    
}


- ( UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    __block NSMutableDictionary *dic = self.dataArray[indexPath.row];
    //删除
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        BOOL isDelete = [FFSQLiteTool deleteDownloadMusicWithMusicUrl:dic[@"musicUrl"]];
        completionHandler (YES);
        if (isDelete) {
            [self getDownloadUrl];
        }
    }];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    return config;
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    
}

- (void)presentToPlayVC:(NSInteger)index {
    FFPlayViewViewController *playerViewVC = [[FFPlayViewViewController alloc] init];
    self.playerViewVC = playerViewVC;
    
    playerViewVC.musicArr = self.dataArray;
    playerViewVC.currentIndex = index;
    playerViewVC.isLocal = YES;
    [playerViewVC setMusicIsPlaying:^(BOOL isPlaying) {
    }];
    [self presentViewController:playerViewVC animated:YES completion:nil];
}

@end
