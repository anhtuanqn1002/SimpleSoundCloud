//
//  DatabaseManager.h
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/11/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSCTrackModel;
@interface SSCDatabaseManager : NSObject

+ (instancetype)shareInstance;

- (NSMutableArray *)getListTrack:(NSString *)table isUseType:(BOOL)isType withColumn:(NSString *)column andValue:(NSString *)value;
- (BOOL)insertRowOfTable:(NSString *)table withModel:(SSCTrackModel *)model;
- (BOOL)updateRowOfTable:(NSString *)table withModel:(SSCTrackModel *)model;
- (BOOL)deleteRowOfTable:(NSString *)table withModel:(SSCTrackModel *)model;
@end
