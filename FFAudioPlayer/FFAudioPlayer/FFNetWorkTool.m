//
//  FFNetWorkTool.m
//  FFAudioPlayer
//
//  Created by 柏富茯 on 6/17/19.
//  Copyright © 2019 柏富茯. All rights reserved.
//

#import "FFNetWorkTool.h"
#import <AFNetworking.h>

@implementation FFNetWorkTool

+ (instancetype)shareNetWorkTool {
    static FFNetWorkTool *sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[self alloc] init];
    });
    return sharedSingleton;
}

- (void)doPostWithURL:(NSString *)urlsString success:(successData)success {
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    NSURL *URL = [NSURL URLWithString:urlsString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
}

@end
