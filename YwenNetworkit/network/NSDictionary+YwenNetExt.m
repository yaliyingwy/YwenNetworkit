//
//  NSDictionary+YwenNetExt.m
//  YwenNetworkit
//
//  Created by ywen on 15/11/13.
//  Copyright © 2015年 ywen. All rights reserved.
//

#import "NSDictionary+YwenNetExt.h"
#import "NSString+YwenNetExt.h"

@implementation NSDictionary (YwenNetExt)

-(NSString*) WY_UrlEncodedKeyValueString {
    
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in self) {
        
        NSObject *value = [self valueForKey:key];
        if([value isKindOfClass:[NSString class]])
        {
             [string appendFormat:@"%@=%@&", [key WY_UrlEncodedString], [((NSString*)value) WY_UrlEncodedString]];
        }
        else
        {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
            NSString *s = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [string appendFormat:@"%@=%@&", [key WY_UrlEncodedString], [s WY_UrlEncodedString]];
        }
        
    }
    
    if([string length] > 0)
        [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
    
    return string;
}

@end
