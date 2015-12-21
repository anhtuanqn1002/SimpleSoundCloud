//
//  NetworkingManager.h
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/8/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSCNetworkingManager : NSObject

+ (instancetype)shareInstance;

- (void)getJsonDataWithURLString:(NSString *)urlString success:(void(^)(NSDictionary *response))success failure:(void(^)(NSError *error))failure;

- (NSString *)getURLWithParameter:(id)param1 andParameter2:(NSInteger)param2 andParameter3:(NSInteger)param3 andParameter4:(id)param4;

- (void)getSuggestDataUseGoogleAPIWithKeyword:(NSString *)keyword success:(void(^)(NSArray *response))success failure:(void(^)(NSError *error))failure;

- (void)getJsonDataSearchWithKeyword:(NSString *)keyword andLimit:(NSInteger)limit andOffset:(NSInteger)offset success:(void(^)(NSArray *response))success failure:(void(^)(NSError *error))failure;

@end
