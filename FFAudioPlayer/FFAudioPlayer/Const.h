//
//  Const.h
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/17/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

//#import <Foundation/Foundation.h>
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface Const : NSObject
//
//@end
//
//NS_ASSUME_NONNULL_END
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

//沙盒音频数组name
#define AUDIOARRAY audioNameArrayXML.xml
#define FFWeakSelf __weak typeof(self) weakSelf = self;

#ifdef DEBUG
#define FFLog(...) printf("第%d行: %s\n\n",__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define FFLog(...)
#endif

#define LOCAL_TITLENAME @"titleName"
#define PICTUREURL_WEB @"pictureUrl"
#define COVERMIDDLE_WEB @"coverMiddle"
#define MUSIC_WEB @"playUrl64"
#define MUSICTITLE_WEB @"title"



