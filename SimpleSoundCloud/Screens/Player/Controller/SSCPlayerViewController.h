//
//  SSCPlayerViewController.h
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/22/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSCTrackModel;
@interface SSCPlayerViewController : UIViewController

+ (instancetype)shareInstance;

@property (strong, nonatomic) SSCTrackModel *currentTrack;
@property (strong, nonatomic) NSMutableArray *listTrack;

@end
