//
//  SSCSearchViewController.m
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/16/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import "SSCSearchViewController.h"
#import "SSCCategoryDetailsTableViewCell.h"
#import "SSCNetworkingManager.h"
#import "SSCTrackModel.h"
#import "SVPullToRefresh.h"
#import "SSCDatabaseManager.h"
#import "SVProgressHUD.h"

@interface SSCSearchViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SSCCategoryDetailsTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *searchResults;

@property (weak, nonatomic) IBOutlet UITableView *suggestTableView;
@property (strong, nonatomic) NSArray *suggestSearchResults;

@property (weak, nonatomic) IBOutlet UIView *viewShadowForSuggestTableView;
@property (assign, nonatomic) NSInteger offset;
@property (assign, nonatomic) NSInteger limit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintForSuggestTableView;

@end

@implementation SSCSearchViewController

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeItemFromSongsToSearch:) name:@"REMOVE_ITEM_TO_SEARCH" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"SSCCategoryDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SSCCategoryDetailsTableViewCell"];
    self.searchResults = [[NSMutableArray alloc] init];
    self.suggestSearchResults = [[NSMutableArray alloc] init];

    //awake offset and limit
    self.offset = 0;
    self.limit = 20;
    
    
    //load more items: using SVInfiniteScrolling
    __weak typeof(self) weakself = self;
    [weakself.tableView addInfiniteScrollingWithActionHandler:^{
        weakself.offset += weakself.limit;
        [weakself getDataSearchWithKeyword:weakself.searchBar.text andLimit:weakself.limit andOffset:weakself.offset];
    }];
//    [self setShadowForTableView:self.suggestTableView withColor:[UIColor grayColor] andOffset:CGSizeMake(0, 3) andRadius:4 andOpacity:1 andCornerRadius:4];
    //set shadow for suggest tableview
    self.suggestTableView.layer.cornerRadius = 5.0;
    // add shadow
//    self.viewShadowForSuggestTableView.backgroundColor = [UIColor redColor];
    self.viewShadowForSuggestTableView.layer.shadowOffset = CGSizeMake(0, 10);
    self.viewShadowForSuggestTableView.layer.shadowRadius = 5.0;
    self.viewShadowForSuggestTableView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.viewShadowForSuggestTableView.layer.shadowOpacity = 1.0;
    
    //hidden viewShadow = hidden suggestTableView
    self.viewShadowForSuggestTableView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Set shadow for SUGGEST TABLEVIEW

//- (void)setShadowForTableView:(UITableView *)tableView withColor:(UIColor *)color andOffset:(CGSize)offset andRadius:(CGFloat)radius andOpacity:(CGFloat)opacity andCornerRadius:(CGFloat)cornerRadius{
////    tableView.clipsToBounds = NO;
////    tableView.layer.masksToBounds = NO;
//    [tableView.layer setShadowColor:[color CGColor]];
//    [tableView.layer setShadowOffset:offset];
//    [tableView.layer setShadowRadius:radius];
//    [tableView.layer setShadowOpacity:opacity];
//    [tableView.layer setCornerRadius:cornerRadius];
//    
//}

#pragma mark - Notification (removing items)

- (void)removeItemFromSongsToSearch:(NSNotification *)notification {
    SSCTrackModel *track = notification.object;
    for (SSCTrackModel *temp in self.searchResults){
        if ([temp.ID isEqual:track.ID]) {
            temp.isSelectedTrack = NO;
            [self.tableView reloadData];
            return;
        }
    }
}

#pragma mark - Tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.suggestTableView) {
        return [self.suggestSearchResults count];
    }
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    if (tableView == self.suggestTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SSCSuggestTableViewCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SSCSuggestTableViewCell"];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.text = [self.suggestSearchResults objectAtIndex:indexPath.row];
        if ([self.suggestSearchResults count] < 6) {
            //set auto constraint
            //because height of suggest tableview and viewShadow follow this constraint
            self.heightConstraintForSuggestTableView.constant = [self.suggestSearchResults count]*30;
        } else {
            //set auto constraint
            self.heightConstraintForSuggestTableView.constant = 200;
        }
        return cell;
    } else {
        SSCCategoryDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SSCCategoryDetailsTableViewCell" forIndexPath:indexPath];
        
        SSCTrackModel *trackTemp = [self.searchResults objectAtIndex:indexPath.row];
        [cell setupViewCellWithArtWork:[trackTemp artworkURL]
                          andTrackName:[trackTemp trackTitle]
                          andTrackLike:[trackTemp likesCount]
                          andTrackPlay:[trackTemp playbackCount]
                           andTrackAdd:[trackTemp isSelectedTrack]
                          withCellType:0];
        
        cell.delegate = self;
        
        //hidden viewShadow = hidden suggestTableView
        if (self.viewShadowForSuggestTableView != nil) {
            self.viewShadowForSuggestTableView.hidden = YES;
            [self.searchBar setShowsCancelButton:NO animated:YES];
            [self.searchBar endEditing:YES];
        }
        
        return cell;
    }
}

#pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.suggestTableView) {
        self.searchBar.text = [self.suggestSearchResults objectAtIndex:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        return 70;
    }
    return 30;
}

#pragma mark - Searchbar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"The search text is: '%@'", searchBar.text);
    [self.searchResults removeAllObjects];
    [self getDataSearchWithKeyword:searchBar.text andLimit:self.limit andOffset:0];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - Get and format data

- (void)getDataSearchWithKeyword:(NSString *)keyword andLimit:(NSInteger)limit andOffset:(NSInteger)offset {
    //dimiss the keyboard and hidden suggest tableview
    [self.searchBar endEditing:YES];
//    self.suggestTableView.hidden = YES;
    self.viewShadowForSuggestTableView.hidden = YES;
    
    __weak typeof (self) weakself = self;
    
    //when the application started, we showed loading progress
    if (self.offset == 0) {
        [SVProgressHUD showWithStatus:@"Searching..."];
    }
    [[SSCNetworkingManager shareInstance] getJsonDataSearchWithKeyword:keyword andLimit:limit andOffset:offset success:^(NSArray *response){
        [weakself.searchResults addObjectsFromArray:response];
        //stop loading
        [SVProgressHUD dismiss];
        //stop load more when it finished
        [weakself.tableView.infiniteScrollingView stopAnimating];
        [weakself formatData];
        [weakself.tableView reloadData];
    }failure:^(NSError *error){
        NSLog(@"%@", error);
        if (error.code == -1002) {
            NSLog(@"No results");
            [SVProgressHUD dismiss];
        }
    }];
}

//event text did change, we show suggest results with google API
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"search text did change");
//    self.suggestTableView.hidden = NO;
    self.viewShadowForSuggestTableView.hidden = NO;
    __weak typeof (self) weakself = self;
    [[SSCNetworkingManager shareInstance] getSuggestDataUseGoogleAPIWithKeyword:searchText success:^(NSArray *response){
        weakself.suggestSearchResults = response;
        
        [weakself.suggestTableView reloadData];
    }failure:^(NSError *error){
        NSLog(@"%@", error);
    }];
}

#pragma mark - Show and hidden searchbar cancel button

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
//    [self.suggestTableView setHidden:YES];
//    hidden viewShadow = hidden suggestTableView
    self.viewShadowForSuggestTableView.hidden = YES;
}

- (void)formatData {
    NSArray *temp = [[SSCDatabaseManager shareInstance] getListTrack:@"Songs" isUseType:NO withColumn:@"" andValue:nil];
    for (SSCTrackModel *temp1 in temp) {
        for (SSCTrackModel *temp2 in self.searchResults) {
            if ([temp1.ID isEqualToString:temp2.ID]) {
                temp2.isSelectedTrack = YES;
            }
        }
    }
}

#pragma mark - Delegate from SSCCategoryTableViewCell

- (void)changeStateButtonAddTrack:(BOOL)state sender:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSLog(@"%ld - %ld", indexPath.section, indexPath.row);
    [[self.searchResults objectAtIndex:indexPath.row] setIsSelectedTrack:state];
    if (state) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SEARCH_ADD_ITEM_TO_SONGS" object:[self.searchResults objectAtIndex:indexPath.row]];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
