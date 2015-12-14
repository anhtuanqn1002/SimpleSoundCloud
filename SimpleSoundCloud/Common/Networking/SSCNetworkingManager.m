//
//  NetworkingManager.m
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/8/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import "SSCNetworkingManager.h"

@implementation SSCNetworkingManager {
    NSString *name;
}

+ (instancetype)shareInstance {
    static SSCNetworkingManager *networkingManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkingManager = [[self alloc] init];
    });
    return networkingManager;
}
//http://www.raywenderlich.com/51127/nsurlsession-tutorial

- (void)getJsonDataWithURL:(NSString *)urlString success:(void(^)(NSDictionary *response))success failure:(void(^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *jsonData = [session dataTaskWithURL:url completionHandler:^(NSData *data,
                                                      NSURLResponse *response,
                                                      NSError *error) {
        if (error) {
            failure(error);
            return;
        }
        
//        NSLog(@"%@", data);
        NSDictionary *dictionary;
        dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSLog(@"%@", dictionary);
        //moving block to MAIN THREAD --> update view
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            success(dictionary);
        }];
    }];
    [jsonData resume];
}

@end
