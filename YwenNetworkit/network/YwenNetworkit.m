//
//  YwenNetworkit.m
//  YwenNetworkit
//
//  Created by ywen on 15/11/9.
//  Copyright © 2015年 ywen. All rights reserved.
//

#import "YwenNetworkit.h"

@implementation YwenNetworkit

-(instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

#pragma mark- 设置

-(void) customInit {
    //默认的设置
    _config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _config.HTTPMaximumConnectionsPerHost = NET_MAX_REQUEST_COUNT;
    _config.timeoutIntervalForRequest = NET_TIMEOUT;
    _config.HTTPAdditionalHeaders = @{
                                      @"Accept": @"application/json"
                                      };
    
    _session = [NSURLSession sessionWithConfiguration:_config];
}


-(void)setConfig:(NSURLSessionConfiguration *)config {
    _config = config;
    _session = [NSURLSession sessionWithConfiguration:config];
}

-(void)setTimeout:(NSTimeInterval)timeout {
    _timeout = timeout;
    _config.timeoutIntervalForRequest = timeout;
    self.config = _config;
}

-(void) setMaxRequestCount:(NSInteger)maxRequestCount {
    _maxRequestCount = maxRequestCount;
    _config.HTTPMaximumConnectionsPerHost = maxRequestCount;
    self.config = _config;
}


#pragma mark- task

-(NSURLSessionDataTask *)request:(NSString *)url params:(NSDictionary *)params files:(NSArray *)files completionHandler:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler{
    if (![url hasPrefix:@"http"] && _host != nil) {
        url = [_host stringByAppendingString: url];
    }
    NSURL *u = [NSURL URLWithString:url];
    NSAssert(u, @"错误的url");
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:u];
    req.HTTPMethod = @"POST";
    
    
    // Build the request body
    NSString *boundary = @"SportuondoFormBoundary";
    NSMutableData *body = [NSMutableData data];
    
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        // Body part for "deviceId" parameter. This is a string.
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *content;
        if ([obj isKindOfClass:[NSString class]]) {
            content = obj;
        }
        else
        {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
            content = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", content] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
   
    
    // Body part for the attachament.
    for (NSDictionary *fileDic in files) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [fileDic objectForKey:@"filed"], [fileDic objectForKey:@"name"]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        id file = [fileDic objectForKey:@"file"];
        id data = [fileDic objectForKey:@"data"];
        if (data != nil) {
            [body appendData:data];
        }
        else if(file != nil)
        {
            [body appendData: [NSData dataWithContentsOfFile:file]];
        }
        
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    req.HTTPBody = body;
    
    [req addValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    // Setup the session
    
    return [_session dataTaskWithRequest:req completionHandler:completionHandler];
}

-(NSURLSessionDataTask *)request:(NSString *)url params:(NSDictionary *)params method:(HttpMethod)method contentType:(ContentType)contentType completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler{
    if (![url hasPrefix:@"http"] && _host != nil) {
        url = [_host stringByAppendingString: url];
    }
    NSURL *u = [NSURL URLWithString:url];
    NSAssert(u, @"错误的url");
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:u];
    switch (method) {
        case POST:
            req.HTTPMethod = @"POST";
            break;
            
        case GET:
            req.HTTPMethod = @"GET";
            break;
            
        default:
            break;
    }
    switch (contentType) {
        case JSON:
        {
            NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
            req.HTTPBody = data;
            [req addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
            break;
            
        case FORM:
        {
            NSMutableString *postBody = [NSMutableString new];
            [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [postBody appendFormat:@"%@=%@&", [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            }];
            if (postBody.length > 0) {
                [postBody deleteCharactersInRange:NSMakeRange(postBody.length-1, 1)];
            }
            [req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            req.HTTPBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];
            break;
        }
            
        default:
            break;
    }
    
    return [_session dataTaskWithRequest:req  completionHandler:completionHandler];
}


#pragma mark- 简单的请求封装

-(void)post:(NSString *)url params:(NSDictionary *)params contentType:(ContentType)contentType success:(void (^)(NSData *))success err:(void (^)(NSError *))err {
    NSURLSessionDataTask *task = [self request:url params:params method:POST contentType:contentType completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        WYLog(@"post url %@, params %@, result %@, error %@", url, params, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                success(data);
            }
            else if (err != nil)
            {
                err(error);
            }
        });
       
    }];
    [task resume];
}

-(void)post:(NSString *)url params:(NSDictionary *)params files:(NSArray *)files success:(void (^)(NSData *))success err:(void (^)(NSError *))err {
    NSURLSessionDataTask *task = [self request:url params:params files:files completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        WYLog(@"post url %@, params %@, files %@, result %@, error %@", url, params, files, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                success(data);
            }
            else if (err != nil)
            {
                err(error);
            }
        });
       
    }];
    [task resume];
}

-(void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(NSData *))success err:(void (^)(NSError *))err {
    NSURLSessionDataTask *task = [self request:url params:params method:GET contentType:FORM completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        WYLog(@"get url %@, params %@, result %@, error %@", url, params, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                success(data);
            }
            else if(err != nil)
            {
                err(error);
            }
        });
       
    }];
    [task resume];
}


#pragma mark- 取消请求
-(void)cancelAllRequest {
    [_session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        for (NSArray *tasks in @[dataTasks, uploadTasks, downloadTasks]) {
            for (NSURLSessionTask *task in tasks) {
                [task cancel];
            }
        }
        
    }];
}

-(void) cancelRequestWithUrl:(NSString *)url {
    [_session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        for (NSArray *tasks in @[dataTasks, uploadTasks, downloadTasks]) {
            for (NSURLSessionTask *task in tasks) {
                NSString *orignUrl = task.originalRequest.URL.absoluteString;
                WYLog(@"orignUrl %@, url %@", orignUrl, url);
                if ([orignUrl containsString:url]) {
                    [task cancel];
                }
            }
        }
        
    }];
}

@end
