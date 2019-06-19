//
//  FFPlayViewViewController.h
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/18/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFPlayViewViewController : UIViewController

@property (nonatomic,strong)NSArray *musicArr;
@property (nonatomic,assign)NSInteger currentIndex;

@end

NS_ASSUME_NONNULL_END
