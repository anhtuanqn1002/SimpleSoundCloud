//
//  AddSongsTableViewController.m
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/8/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import "SSCCategoryDetailsTableViewController.h"
#import "SSCCategoryDetailsTableViewCell.h"
#import "SSCNetworkingManager.h"
#import "SSCSongsTableViewController.h"
#import "SSCTrackModel.h"
#import "SVProgressHUD.h"
#import "SSCDatabaseManager.h"
#import "SVPullToRefresh.h"

@interface SSCCategoryDetailsTableViewController () <SSCCategoryDetailsTableViewCellDelegate>

@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSMutableArray *songs;

//using get next data (load more)
//@property (nonatomic, strong) NSString *nextLink;

@end

@implementation SSCCategoryDetailsTableViewController

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeItemFromSongsToCategoryDetails:) name:@"REMOVE_ITEM_TO_CATEGORY" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //show progress
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SSCCategoryDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SSCCategoryDetailsTableViewCell"];
    
    //start with contents
    self.limit = 50;
    self.offset = 0;
    
    if (self.genres != nil) {
        NSLog(@"%@", self.genres);
        self.title = self.genres;
        
        self.songs = [[NSMutableArray alloc] init];
        [self setupDataWithGenre:self.genres andLimit:self.limit andOffset:self.offset];
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor purpleColor];
        self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self action:@selector(getLatest) forControlEvents:UIControlEventValueChanged];
        
    }
    //load more items: using SVInfiniteScrolling
    __weak typeof(self) weakself = self;
    [weakself.tableView addInfiniteScrollingWithActionHandler:^{
        weakself.offset = [weakself.songs count];
        [weakself setupDataWithGenre:weakself.genres andLimit:weakself.limit andOffset:weakself.offset];
    }];

}

- (void)getLatest {
    NSLog(@"pull to refresh...");
    [self setupDataWithGenre:self.genres andLimit:self.limit andOffset:self.offset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup data
/*
 get data(json). Parsing json to NSMutableArray
 */
- (void)setupDataWithGenre:(NSString *)genre andLimit:(NSInteger)limit andOffset:(NSInteger)offset {
    NSString *url = [[SSCNetworkingManager shareInstance] getURLWithParameter:genre andParameter2:(NSInteger)limit andParameter3:offset andParameter4:@"Songs"];
    [[SSCNetworkingManager shareInstance] getJsonDataWithURLString:url success:^(NSDictionary *response) {
        //get all keys of response
        __weak typeof(self)weakself = self;
        NSArray *array = [response objectForKey:@"tracks"];
        //when loading progress finished, we need dismiss SVProgressHUD
        [SVProgressHUD dismissWithDelay:0.01f];
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
            track.genre = weakself.genres;
            [weakself.songs addObject:track];
        }
        
        if (weakself.refreshControl) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
            NSDictionary *attributedDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributedDictionary];
            weakself.refreshControl.attributedTitle = attributedTitle;
            [weakself.refreshControl endRefreshing];
        }
        
        //stop load more when it finished
        [weakself.tableView.infiniteScrollingView stopAnimating];
        [weakself formatData];
        [weakself.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)formatData {
    NSArray *songsTemp = [[SSCDatabaseManager shareInstance] getListTrack:@"Songs" isUseType:YES withColumn:@"genre" andValue:self.genres];
    for (SSCTrackModel *temp1 in songsTemp) {
        for (SSCTrackModel *temp2 in self.songs) {
            if ([temp1.ID isEqualToString:temp2.ID]) {
                temp2.isSelectedTrack = YES;
            }
        }
    }
}

#pragma mark - Delegate from SSCCategoryDetailsTableViewCell

- (void)changeStateButtonAddTrack:(BOOL)state sender:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSLog(@"%ld - %ld", indexPath.section, indexPath.row);
    [[self.songs objectAtIndex:indexPath.row] setIsSelectedTrack:state];
    if (state) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CATEGORYDETAILS_ADD_ITEM_TO_SONGS" object:[self.songs objectAtIndex:indexPath.row]];
    }
}

#pragma mark - Removing from songs to category details

- (void)removeItemFromSongsToCategoryDetails:(NSNotification *)notification {
    SSCTrackModel *track = notification.object;
    for (SSCTrackModel *temp in self.songs){
        if ([temp.ID isEqual:track.ID]) {
            temp.isSelectedTrack = NO;
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%ld", [self.songs count]);
    return [self.songs count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSCCategoryDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SSCCategoryDetailsTableViewCell" forIndexPath:indexPath];
    // Configure the cell...
    SSCTrackModel *trackTemp = [self.songs objectAtIndex:indexPath.row];
    [cell setupViewCellWithArtWork:[trackTemp artworkURL]
                      andTrackName:[trackTemp trackTitle]
                      andTrackLike:[trackTemp likesCount]
                      andTrackPlay:[trackTemp playbackCount]
                      andTrackAdd:[trackTemp isSelectedTrack]
                      withCellType:0];
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - fix height of row

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
