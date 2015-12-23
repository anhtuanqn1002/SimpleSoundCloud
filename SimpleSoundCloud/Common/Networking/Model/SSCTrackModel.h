//
//  TrackModel.h
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/9/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSCTrackModel : NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *trackTitle;
@property (nonatomic, strong) NSString *artworkURL;
@property (nonatomic, assign) NSInteger likesCount;
@property (nonatomic, assign) NSInteger playbackCount;
@property (nonatomic, assign) BOOL isSelectedTrack;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *streamURL;

@end
