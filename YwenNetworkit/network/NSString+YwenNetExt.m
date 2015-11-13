//
//  NSString+YwenNetExt.m
//  YwenNetworkit
//
//  Created by ywen on 15/11/13.
//  Copyright © 2015年 ywen. All rights reserved.
//

#import "NSString+YwenNetExt.h"

@implementation NSString (YwenNetExt)

- (NSString*) WY_UrlEncodedString {
    
    NSMutableCharacterSet *cs = [NSMutableCharacterSet new];
    [cs addCharactersInString:@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| "];
    NSString  *encodedString = [self stringByAddingPercentEncodingWithAllowedCharacters:[cs invertedSet]];
    
    
    if(!encodedString)
        encodedString = @"";
    
    return encodedString;
}

- (NSString*) WY_UrlDecodedString {
    NSString *decodedString = [self stringByRemovingPercentEncoding];
    return (!decodedString) ? @"" : [decodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}

@end
