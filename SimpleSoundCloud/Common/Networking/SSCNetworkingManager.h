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

- (void)getJsonDataWithGenre:(NSString *)genre success:(void(^)(NSDictionary *response))success failure:(void(^)(NSError *error))failure;

- (void)getJsonDataWithGenre:(NSString *)genre andLimit:(NSInteger)limit andOffset:(NSInteger)offset success:(void(^)(NSArray *response))success failure:(void(^)(NSError *error))failure;

- (void)getSuggestDataUseGoogleAPIWithKeyword:(NSString *)keyword success:(void(^)(NSArray *response))success failure:(void(^)(NSError *error))failure;

- (void)getJsonDataSearchWithKeyword:(NSString *)keyword andLimit:(NSInteger)limit andOffset:(NSInteger)offset success:(void(^)(NSArray *response))success failure:(void(^)(NSError *error))failure;

@end
