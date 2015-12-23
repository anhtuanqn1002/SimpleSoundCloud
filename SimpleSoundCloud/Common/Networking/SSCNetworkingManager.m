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

#pragma mark - ShareInstance

+ (instancetype)shareInstance {
    static SSCNetworkingManager *networkingManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkingManager = [[self alloc] init];
    });
    return networkingManager;
}

#pragma mark - Get data for Category

- (void)getJsonDataWithGenre:(NSString *)genre success:(void(^)(NSDictionary *response))success failure:(void(^)(NSError *error))failure {
    NSString *urlString = [NSString stringWithFormat:@"https://api-v2.soundcloud.com/explore/%@", genre];
    NSURL *url = [NSURL URLWithString:urlString];
    
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
        
        NSLog(@"%@", dictionary);
        //moving block to MAIN THREAD --> update view
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            success(dictionary);
        }];
    }];
    [jsonData resume];
}

#pragma mark - Get data for Category details

- (void)getJsonDataWithGenre:(NSString *)genre andLimit:(NSInteger)limit andOffset:(NSInteger)offset success:(void(^)(NSArray *response))success failure:(void(^)(NSError *error))failure {
    NSString *urlString = [NSString stringWithFormat:@"https://api-v2.soundcloud.com/explore/%@?limit=%ld&offset=%ld", genre, limit, offset];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
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
        
        NSArray *array = [dictionary objectForKey:@"tracks"];
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (NSInteger j = 0; j < [array count]; j++) {
            NSLog(@"%@", [array objectAtIndex:j]);
            NSDictionary *temp = [array objectAtIndex:j];
            NSLog(@"%@", temp);
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
            
            if ([[temp valueForKey:@"stream_url"] isEqual:[NSNull null]]) {
                track.streamURL = @"";
            } else {
                track.streamURL = [temp valueForKey:@"stream_url"];
            }
            
            track.genre = genre;
            [results addObject:track];
        }
        
        NSLog(@"%@", dictionary);
        //moving block to MAIN THREAD --> update view
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            success(results);
        }];
    }];
    [jsonData resume];
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
            
            if ([[temp valueForKey:@"stream_url"] isEqual:[NSNull null]]) {
                track.streamURL = @"";
            } else {
                track.streamURL = [temp valueForKey:@"stream_url"];
            }
            
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
