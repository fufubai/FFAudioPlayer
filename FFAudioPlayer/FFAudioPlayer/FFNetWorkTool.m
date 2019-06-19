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

+ (void)doPostWithURLString:(NSString *)urlString params:(id _Nullable)params success:(successData)success {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json",@"application/json",@"text/javascript",@"text/html", @"application/javascript", @"text/js", @"application/x-javascript", nil];
    
    [manager.requestSerializer setHTTPShouldHandleCookies:YES];
    
    NSMutableString *url =nil;
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:urlString]];
    url = [NSMutableString stringWithString:urlString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"请求链接=%@,参数=%@,返回值=%@",url,params,responseObject);
            success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"请求链接=%@,参数=%@,错误码=%@",url,params,error);
        }];
    });
}

+ (void)doGetWithURLString:(NSString *)urlString params:(id _Nullable)params success:(successData)success {
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", nil]];
    
    [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            
        }
    }];
}


@end
