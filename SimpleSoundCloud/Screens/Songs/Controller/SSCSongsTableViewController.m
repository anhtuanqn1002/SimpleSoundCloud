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
#import "SSCPlayerViewController.h"
#import "AppDelegate.h"

@interface SSCSongsTableViewController ()

@property (nonatomic, strong) NSMutableArray *songs;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;

@end

@implementation SSCSongsTableViewController


- (void)awakeFromNib {
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //alloc and load data to songs
    self.songs = [[NSMutableArray alloc] init];
    self.songs = [[SSCDatabaseManager shareInstance] getListTrack:@"Songs" isUseType:NO withColumn:nil andValue:nil];
    
    //  ---------------------------------------
    //  register to recieve all notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addItemFromCategoryDetais:) name:@"CATEGORYDETAILS_ADD_ITEM_TO_SONGS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addItemFromSearch:) name:@"SEARCH_ADD_ITEM_TO_SONGS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOnPlayerScreen:) name:@"TURN_ON_PLAYER" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOffPlayerScreen:) name:@"TURN_OFF_PLAYER" object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SSCCategoryDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SSCCategoryDetailsTableViewCell"];
    
    //adding right bar button
    self.rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(rightBarButtonClick:)];
    self.rightBarButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    
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

#pragma mark - Add items from Category and Search

- (void)addItemFromCategoryDetais:(NSNotification *)notification {
    SSCTrackModel *track = notification.object;
    [self.songs addObject:track];
    [self updateData];
    if ([[SSCDatabaseManager shareInstance] insertRowOfTable:@"Songs" withModel:track]) {
        NSLog(@"Adding item from category details is success");
    } else {
        NSLog(@"Adding item from category details failed");
    }
}

- (void)addItemFromSearch:(NSNotification *)notification {
    SSCTrackModel *track = notification.object;
    [self.songs addObject:track];
    [self updateData];
    if ([[SSCDatabaseManager shareInstance] insertRowOfTable:@"Songs" withModel:track]) {
        NSLog(@"Adding item from search is success");
    } else {
        NSLog(@"Adding item from search failed");
    }
}

#pragma mark - Turn on - turn off player screen notification

- (void)turnOnPlayerScreen:(id)sender {
    [self.rightBarButton setEnabled:YES];
}

- (void)turnOffPlayerScreen:(id)sender {
    [self.rightBarButton setEnabled:NO];
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

#pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *nvSSCPplayer = [[UINavigationController alloc] initWithRootViewController:[SSCPlayerViewController shareInstance]];
    [self presentViewController:nvSSCPplayer animated:YES completion:nil];
    [SSCPlayerViewController shareInstance].title = @"NOW PLAYING";
    
    [SSCPlayerViewController shareInstance].currentTrack = [self.songs objectAtIndex:indexPath.row];
    [SSCPlayerViewController shareInstance].listTrack = self.songs;
    [SSCPlayerViewController shareInstance].isChangeTrack = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //push notification from song to category
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_ITEM_TO_CATEGORY" object:[self.songs objectAtIndex:indexPath.row]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_ITEM_TO_SEARCH" object:[self.songs objectAtIndex:indexPath.row]];
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

#pragma mark - Right barbutton event --> show player screen

- (void)rightBarButtonClick:(id)sender {
    UINavigationController *nvSSCPplayer = [[UINavigationController alloc] initWithRootViewController:[SSCPlayerViewController shareInstance]];
    [self presentViewController:nvSSCPplayer animated:YES completion:nil];
    [SSCPlayerViewController shareInstance].title = @"NOW PLAYING";
    [SSCPlayerViewController shareInstance].isChangeTrack = NO;
}

#pragma mark - Sending items to Player

- (void)sendingItemsToPlayer:(NSIndexPath *)indexPath sending:(void(^)(SSCTrackModel *model))send {
    SSCTrackModel *md = [self.songs objectAtIndex:indexPath.row];
    send(md);
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
