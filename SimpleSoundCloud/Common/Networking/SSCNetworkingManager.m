//
//  NetworkingManager.m
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/8/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import "SSCNetworkingManager.h"
#import "SSCTrackModel.h"
#import "NSString+Encoding.h"

@interface SSCNetworkingManager()

@property (nonatomic, assign) BOOL isFinish;

@end

@implementation SSCNetworkingManager

+ (instancetype)shareInstance {
    static SSCNetworkingManager *networkingManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkingManager = [[self alloc] init];
    });
    return networkingManager;
}
//http://www.raywenderlich.com/51127/nsurlsession-tutorial

- (void)getJsonDataWithURLString:(NSString *)urlString success:(void(^)(NSDictionary *response))success failure:(void(^)(NSError *error))failure {
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

- (NSString *)getURLWithParameter:(id)param1 andParameter2:(NSInteger)param2 andParameter3:(NSInteger)param3 andParameter4:(id)param4 {
    NSString *url = @"";
    if ([param4 isEqualToString:@"Category"]) {
        url = [NSString stringWithFormat:@"https://api-v2.soundcloud.com/explore/%@",param1];
    } else if ([param4 isEqualToString:@"Songs"]) {
        url = [NSString stringWithFormat:@"https://api-v2.soundcloud.com/explore/%@?limit=%ld&offset=%ld", param1, param2, param3];
    } else if ([param4 isEqualToString:@"SuggestSearch"]) {
        url = [NSString stringWithFormat:@"http://suggestqueries.google.com/complete/search?q=%@&ds=yt&client=firefox&hjson=t&cp=3", param1];
    } else if ([param4 isEqualToString:@"Search"]) {
        url = [NSString stringWithFormat:@"https://api-v2.soundcloud.com/search?q=%@&limit=%ld&offset=%ld", param1, param2, param3];
    }
    return url;
}

#pragma mark - Get data for suggest

- (void)getSuggestDataUseGoogleAPIWithKeyword:(NSString *)keyword success:(void(^)(NSArray *response))success failure:(void(^)(NSError *error))failure {
    keyword = [keyword URLEncodeStringFromString:keyword];
    NSString *urlString = [NSString stringWithFormat:@"http://suggestqueries.google.com/complete/search?q=%@&ds=yt&client=firefox&hjson=t&cp=3", keyword];
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"%@",url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *jsonData = [session dataTaskWithURL:url completionHandler:^(NSData *data,
                                                                                      NSURLResponse *response,
                                                                                      NSError *error) {
        if (error) {
            failure(error);
            return;
        }
        //convert data to string with asciiEncoding
        //convert string back data because a lot of character special
        NSString *stringData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *jsonArray;
        jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSLog(@"%@", jsonArray);
        //moving block to MAIN THREAD --> update view
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //data's response have 2 array, first array(index = 0) contain search text and second array(index = 1) contain result
            success([jsonArray objectAtIndex:1]);
        }];
    }];
    
    [jsonData resume];
}

#pragma mark - Get data for searching

- (void)getJsonDataSearchWithKeyword:(NSString *)keyword andLimit:(NSInteger)limit andOffset:(NSInteger)offset success:(void(^)(NSArray *response))success failure:(void(^)(NSError *error))failure {
    NSString *urlString = [NSString stringWithFormat:@"https://api-v2.soundcloud.com/search?q=%@&limit=%ld&offset=%ld", keyword, limit, offset];
    NSString *urlString2 = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *url = [NSURL URLWithString:urlString2];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *jsonData = [session dataTaskWithURL:url completionHandler:^(NSData *data,
                                                                                      NSURLResponse *response,
                                                                                      NSError *error) {
        if (error) {
            failure(error);
            return;
        }
        NSDictionary *dictionary;
        dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray *array = [dictionary objectForKey:@"collection"];
        NSMutableArray *jsonDataArray = [[NSMutableArray alloc] init];

        for (NSInteger j = 0; j < [array count]; j++) {

            NSDictionary *temp = [array objectAtIndex:j];

            //id artwork_url title likes_count playback_count
            SSCTrackModel *track = [[SSCTrackModel alloc] init];
            if ([[temp valueForKey:@"id"] isEqual:[NSNull null]]) {
                NSLog(@"ID is equal null --> Error!");
            } else {
                track.ID = [[temp valueForKey:@"id"] stringValue];
            }
            
            if ([[temp valueForKey:@"title"] isEqual:[NSNull null]]) {
                track.trackTitle = @"";
            } else {
                track.trackTitle = [temp valueForKey:@"title"];
            }
            
            if ([[temp valueForKey:@"artwork_url"] isEqual:[NSNull null]]) {
                track.artworkURL = @"";
            } else {
                track.artworkURL = [temp valueForKey:@"artwork_url"];
            }
            
            if ([[temp valueForKey:@"likes_count"] isEqual:[NSNull null]]) {
                track.likesCount = 0;
            } else {
                track.likesCount = [[temp valueForKey:@"likes_count"] intValue];
            }
            
            if ([[temp valueForKey:@"playback_count"] isEqual:[NSNull null]]) {
                track.playbackCount = 0;
            } else {
                track.playbackCount = [[temp valueForKey:@"playback_count"] intValue];
            }
            track.genre = @"Search";
            [jsonDataArray addObject:track];
        }

        //moving block to MAIN THREAD --> update view
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            success(jsonDataArray);
        }];
    }];
    [jsonData resume];
}

@end
