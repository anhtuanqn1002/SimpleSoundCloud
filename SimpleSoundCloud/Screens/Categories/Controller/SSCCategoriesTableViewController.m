//
//  FirstViewController.m
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/7/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import "SSCCategoriesTableViewController.h"
#import "SSCNetworkingManager.h"
#import "SSCCategoryDetailsTableViewController.h"
#import "SVProgressHUD.h"

@interface SSCCategoriesTableViewController ()

@property (nonatomic, strong) NSDictionary *categories;

@end

@implementation SSCCategoriesTableViewController

#pragma mark - viewDidLoad

- (void)awakeFromNib {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.categories = [[NSDictionary alloc] init];
    
    //show SVProgressHUD
    [SVProgressHUD showWithStatus:@"Loading..."];
    [self setupData];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(getLatest) forControlEvents:UIControlEventValueChanged];
    
}

- (void)getLatest {
    NSLog(@"pull to refresh...");
    [self setupData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup data when starting
//get data from URL https://api-v2.soundcloud.com/explore/categories
//using parse json, set data to NSMutableArray
- (void)setupData {
//    NSString *urlString = @"https://api-v2.soundcloud.com/explore/categories";
    __weak typeof(self) self_weak = self;
    [[SSCNetworkingManager shareInstance] getJsonDataWithGenre:@"categories" success:^(NSDictionary *response) {
        self_weak.categories = response;
        [self_weak.tableView reloadData];
        //dimiss SVProgressHUD
        [SVProgressHUD dismissWithDelay:0.0f];
        
        if (self.refreshControl) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
            NSDictionary *attributedDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributedDictionary];
            self.refreshControl.attributedTitle = attributedTitle;
            [self.refreshControl endRefreshing];
        }
    } failure:^(NSError *error) {
        // code
        NSLog(@"Failed!");
    }];
}

#pragma mark - TableView Datasource

//number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *keys = [[NSArray alloc] initWithArray:[self.categories allKeys]];
    return [keys count];
}

//number of row each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.categories valueForKey:[[self.categories allKeys] objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    cell.textLabel.text = self.categories[self.categories.allKeys[indexPath.section]][indexPath.row];
    return cell;
}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CategoryDetails"]) {
        NSLog(@"Go to category details");
        SSCCategoryDetailsTableViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        controller.genres = self.categories[self.categories.allKeys[indexPath.section]][indexPath.row];
//        NSLog(@"%@",self.categories[self.categories.allKeys[indexPath.section]][indexPath.row]);
    }
}

#pragma mark - Set title for HEADER and FOOTER in section

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *keys = [[NSArray alloc] initWithArray:[self.categories allKeys]];
    return [keys objectAtIndex:section];
}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    return @"footer";
//}

@end
