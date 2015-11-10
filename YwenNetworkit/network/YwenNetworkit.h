//
//  YwenNetworkit.h
//  YwenNetworkit
//
//  Created by ywen on 15/11/9.
//  Copyright © 2015年 ywen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    POST,
    GET
} HttpMethod;

typedef enum : NSUInteger {
    JSON,
    FORM,
} ContentType;

#ifdef DEBUG
#define WYLog(...) NSLog(__VA_ARGS__)
#else
#define WYLog(...)
#endif

#define NET_TIMEOUT 40
#define NET_MAX_REQUEST_COUNT 4

@interface YwenNetworkit : NSObject

@property (strong, nonatomic) NSURLSession *session;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (assign, nonatomic) NSInteger maxRequestCount;
@property (strong, nonatomic) NSURLSessionConfiguration *config;


-(NSURLSessionDataTask *) request:(NSString *) url params:(NSDictionary *) params files:(NSArray *) files completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
-(NSURLSessionDataTask *) request:(NSString *)url params:(NSDictionary *)params method:(HttpMethod) method contentType:(ContentType) contentType completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

-(void) post:(NSString *) url params:(NSDictionary *) params contentType:(ContentType) contentType success:(void(^)(NSData *data)) success err:(void(^)(NSError *error)) err;

-(void) get:(NSString *) url params:(NSDictionary *) params success:(void(^)(NSData *data)) success err:(void(^)(NSError *error)) err;


-(void) cancelAllRequest;

-(void) cancelRequestWithUrl:(NSString *) url;

@end
