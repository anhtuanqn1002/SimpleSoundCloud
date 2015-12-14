//
//  SecondViewController.m
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/7/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import "SSCSongsTableViewController.h"
#import "SSCCategoryDetailsTableViewController.h"
#import "SSCCategoryDetailsTableViewCell.h"
#import "SSCTrackModel.h"
#import "SSCDatabaseManager.h"

@interface SSCSongsTableViewController ()

@property (nonatomic, strong) NSMutableArray *songs;

@end

@implementation SSCSongsTableViewController


- (void)awakeFromNib {
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //alloc and load data to songs
    self.songs = [[NSMutableArray alloc] init];
    self.songs = [[SSCDatabaseManager shareInstance] getListTrack:@"Songs" isUseType:NO withColumn:nil andValue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addItem:) name:@"ADD_ITEM_TO_SONGS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeItem:) name:@"REMOVE_ITEM_TO_SONGS" object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"SSCCategoryDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SSCCategoryDetailsTableViewCell"];
    [self updateData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", [self.songs count]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Update data

- (void)updateData {
    self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", [self.songs count]];
    [self.tableView reloadData];
}

#pragma mark - Add and remove items from Category

- (void)addItem:(NSNotification *)notification {
    SSCTrackModel *track = notification.object;
    [self.songs addObject:track];
    [self updateData];
    if ([[SSCDatabaseManager shareInstance] insertRowOfTable:@"Songs" withModel:track]) {
        NSLog(@"Insert a row is success");
    } else {
        NSLog(@"Insert a row is failed");
    }
}

- (void)removeItem:(NSNotification *)notification {
    SSCTrackModel *track = notification.object;
    [self.songs removeObject:track];
    [self updateData];
    if ([[SSCDatabaseManager shareInstance] deleteRowOfTable:@"Songs" withModel:track]) {
        NSLog(@"Delete a row is success");
    } else {
        NSLog(@"Delete a row is failed");
    }
}

#pragma mark - Table data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSCCategoryDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SSCCategoryDetailsTableViewCell" forIndexPath:indexPath];
    SSCTrackModel *track = [self.songs objectAtIndex:indexPath.row];
    [cell setupViewCellWithArtWork:track.artworkURL
                      andTrackName:track.trackTitle
                      andTrackLike:track.likesCount
                      andTrackPlay:track.playbackCount
                      andTrackAdd:NO
                      withCellType:1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //push notification from song to category
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_ITEM_TO_CATEGORY" object:[self.songs objectAtIndex:indexPath.row]];
        SSCTrackModel *track = [self.songs objectAtIndex:indexPath.row];
        [self.songs removeObject:track];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", [self.songs count]];
        if ([[SSCDatabaseManager shareInstance] deleteRowOfTable:@"Songs" withModel:track]) {
            NSLog(@"Delete a row is success");
        } else {
            NSLog(@"Delete a row is failed");
        }
    }
}

#pragma mark - Set height of row

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
