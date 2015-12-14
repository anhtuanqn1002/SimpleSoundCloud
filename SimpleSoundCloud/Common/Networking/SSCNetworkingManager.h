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

- (void)getJsonDataWithURL:(NSString *)urlString success : (void (^)(NSDictionary *response))success failure:(void(^)(NSError *error))failure;

@end
