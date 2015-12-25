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
#import "SSCPlayerViewController.h"

@interface SSCCategoryDetailsTableViewController () <SSCCategoryDetailsTableViewCellDelegate>

@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSMutableArray *songs;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
//using get next data (load more)
//@property (nonatomic, strong) NSString *nextLink;

@end

@implementation SSCCategoryDetailsTableViewController

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeItemFromSongsToCategoryDetails:) name:@"REMOVE_ITEM_TO_CATEGORY" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOnPlayerScreen:) name:@"TURN_ON_PLAYER" object:nil];
    
    //adding right bar button
    self.rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(rightBarButtonClick:)];
    
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.rightBarButton.enabled = self.isShow;
    
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

#pragma mark - Turn on - turn off player screen notification

- (void)turnOnPlayerScreen:(id)sender {
    [self.rightBarButton setEnabled:YES];
}

#pragma mark - Setup data
/*
 get data(json). Parsing json to NSMutableArray
 */
- (void)setupDataWithGenre:(NSString *)genre andLimit:(NSInteger)limit andOffset:(NSInteger)offset {
    [[SSCNetworkingManager shareInstance] getJsonDataWithGenre:genre andLimit:limit andOffset:offset success:^(NSArray *response) {
        __weak typeof(self)weakself = self;
        //when loading progress finished, we need dismiss SVProgressHUD
        [SVProgressHUD dismissWithDelay:0.01f];
        //get data
        [weakself.songs addObjectsFromArray:response];
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

#pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //------------------------------
    // playing music
    UINavigationController *nvSSCPplayer = [[UINavigationController alloc] initWithRootViewController:[SSCPlayerViewController shareInstance]];
    [self presentViewController:nvSSCPplayer animated:YES completion:nil];
    [SSCPlayerViewController shareInstance].title = @"NOW PLAYING";
    
    [SSCPlayerViewController shareInstance].currentTrack = [self.songs objectAtIndex:indexPath.row];
    [SSCPlayerViewController shareInstance].listTrack = self.songs;
    [SSCPlayerViewController shareInstance].isChangeTrack = YES;
    //------------------------------
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Right barbutton event --> show player screen

- (void)rightBarButtonClick:(id)sender {
    UINavigationController *nvSSCPplayer = [[UINavigationController alloc] initWithRootViewController:[SSCPlayerViewController shareInstance]];
    [self presentViewController:nvSSCPplayer animated:YES completion:nil];
    [SSCPlayerViewController shareInstance].title = @"NOW PLAYING";
    [SSCPlayerViewController shareInstance].isChangeTrack = NO;
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
