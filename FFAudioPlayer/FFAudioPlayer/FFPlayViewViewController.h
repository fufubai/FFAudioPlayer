//
//  FFPlayViewViewController.h
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/18/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^musicIsPlaying)(BOOL isPlaying);

@interface FFPlayViewViewController : UIViewController


@property (nonatomic, copy) void(^musicIsPlaying)(BOOL isPlaying);
@property (nonatomic,strong)NSArray *musicArr;
@property (nonatomic,assign)NSInteger currentIndex;

@property (nonatomic,assign)BOOL isLocal;//本地音频

@end

NS_ASSUME_NONNULL_END
