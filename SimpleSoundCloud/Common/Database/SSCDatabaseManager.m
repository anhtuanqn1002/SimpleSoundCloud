//
//  DatabaseManager.m
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/11/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import "SSCDatabaseManager.h"
#import "FMDB.h"
#import "SSCTrackModel.h"

@interface SSCDatabaseManager ()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation SSCDatabaseManager

+ (instancetype)shareInstance {
    static SSCDatabaseManager *databasemanager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databasemanager = [[self alloc] init];
    });
    return databasemanager;
}

- (instancetype)init {
    if (self = [super init]) {
        //create database
        NSString *dataName = @"database.db";
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:dataName];
        
        //if it does not exists the database, FMDatabase would create a new database
        self.db = [FMDatabase databaseWithPath:path];
        NSLog(@"%@", path);
        
        //opening the database
        [self.db open];
        
        NSString *sql = @"CREATE TABLE IF NOT EXISTS Songs (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, idTrack TEXT DEFAULT NULL, trackTitle TEXT DEFAULT NULL, artworkURL TEXT DEFAULT NULL, likesCount INTEGER DEFAULT 0, playbackCount INTEGER DEFAULT 0, isSelectedTrack INTEGER DEFAULT 0, genre TEXT DEFAULT NULL)";
        //create a table to database
        BOOL result = [self.db executeUpdate:sql];
        
        if (result) {
            NSLog(@"Successfully");
        } else {
            NSLog(@"Failed");
        }
        
        //closing the database
        [self.db close];
        //create table
    }
    return self;
}

- (NSMutableArray *)getListTrack:(NSString *)table isUseType:(BOOL)isType withColumn:(NSString *)column andValue:(NSString *)value {
    NSString *sql = [NSString stringWithFormat:@"Select * from %@", table];
    
    if (isType) {
        sql = [NSString stringWithFormat:@"Select * from %@ where %@ = '%@'", table, column, value];
    }
    [self.db open];
    FMResultSet *result = [self.db executeQuery:sql];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    while ([result next]) {
        SSCTrackModel *trackmodel = [[SSCTrackModel alloc] init];
        trackmodel.ID = [result stringForColumn:@"idTrack"];
        trackmodel.trackTitle = [result stringForColumn:@"trackTitle"];
        trackmodel.artworkURL = [result stringForColumn:@"artworkURL"];
        trackmodel.likesCount = [result intForColumn:@"likesCount"];
        trackmodel.playbackCount = [result intForColumn:@"playbackCount"];
        NSInteger selected = [result intForColumn:@"isSelectedTrack"];
        if (selected == 0) {
            trackmodel.isSelectedTrack = NO;
        } else {
            trackmodel.isSelectedTrack = YES;
        }
        trackmodel.genre = [result stringForColumn:@"genre"];
        
        NSLog(@"%@", trackmodel.ID);
        NSLog(@"%@", trackmodel.trackTitle);
        NSLog(@"%ld", selected);
        [temp addObject:trackmodel];
    }
    
    [self.db close];
    return temp;
}

- (BOOL)insertRowOfTable:(NSString *)table withModel:(SSCTrackModel *)model {
    NSInteger selected = 1;
    if (!model.isSelectedTrack) {
        selected = 0;
    }
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (idTrack, trackTitle, artworkURL, likesCount, playbackCount, isSelectedTrack, genre) VALUES ('%@','%@', '%@', %ld, %ld, %ld, '%@')", table, model.ID, model.trackTitle, model.artworkURL, model.likesCount, model.playbackCount, selected, model.genre];
    [self.db open];
    BOOL result = [self.db executeUpdate:sql];
    [self.db close];
    return result;
}

- (BOOL)updateRowOfTable:(NSString *)table withModel:(SSCTrackModel *)model {
    NSInteger selected = 1;
    if (!model.isSelectedTrack) {
        selected = 0;
    }
    NSString *sql = [NSString stringWithFormat:@"UPDATE '%@' set trackTitle = '%@', artworkURL = '%@', likesCount = %ld, playbackCount = %ld, isSelectedTrack = %ld, genre = '%@' where id = '%@'", table, model.trackTitle, model.artworkURL, model.likesCount, model.playbackCount, selected, model.ID, model.genre];
    [self.db open];
    BOOL result = [self.db executeUpdate:sql];
    [self.db close];
    return result;
}

- (BOOL)deleteRowOfTable:(NSString *)table withModel:(SSCTrackModel *)model {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM '%@' where idTrack = '%@'", table, model.ID];
    [self.db open];
    BOOL result = [self.db executeUpdate:sql];
    [self.db close];
    return result;
}

@end
