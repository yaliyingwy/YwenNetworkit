//
//  YwenNetworkitTests.m
//  YwenNetworkitTests
//
//  Created by ywen on 15/11/9.
//  Copyright © 2015年 ywen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YwenNetworkit.h"

@interface YwenNetworkitTests : XCTestCase

@end

@implementation YwenNetworkitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
   
}

-(void) testGet {
    __block BOOL _done = NO;
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        YwenNetworkit *net = [[YwenNetworkit alloc] init];
        net.host = @"http://www.baidu.com/";
        [net get:@"/foo" params:nil success:^(NSData *data) {
            NSLog(@"done--");
            _done = YES;
        } err:^(NSError *error) {
            NSLog(@"error %@", error);
            _done = YES;
        }];
        [net cancelRequestWithUrl:@"/foo"];
    });
    
    NSRunLoop *lp = [NSRunLoop currentRunLoop];
    
    while (!_done) {
        [lp runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
