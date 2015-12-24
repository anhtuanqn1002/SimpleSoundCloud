//
//  SSCPlayerViewController.m
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/22/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import "SSCPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SSCPlayerBarViewController.h"
#import "SSCTrackModel.h"

#define CLIENT_ID @"e0d5195b63d3e78ad2422fa9871fe2b1"

@interface SSCPlayerViewController ()

//do not use AVAudioPlayer because that is not playing a stream (only offline file)
@property (strong, nonatomic) AVPlayer *playerControl;

@property (weak, nonatomic) IBOutlet UIImageView *avatarPlayer;
@property (weak, nonatomic) IBOutlet UISlider *playerSlider;
//@property (strong, nonatomic) SSCPlayerBarViewController *playerBar;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleTrack;

@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *rewardButton;
@property (weak, nonatomic) IBOutlet UIButton *loopButton;

@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) BOOL isChangeTrack;
@property (strong, nonatomic) NSString *currentTrack;

@end

@implementation SSCPlayerViewController

+ (instancetype)shareInstance {
    static SSCPlayerViewController *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[self alloc] init];
    });
    return player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //  -------------------------------------------
    //    Add bar button
    UIBarButtonItem *dropDownBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuFilled-100.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(dropDownBarButton:)];
    self.navigationItem.leftBarButtonItem = dropDownBarButton;
    //  -------------------------------------------
    
//    self.playerBar = [[SSCPlayerBarViewController alloc] initWithNibName:@"SSCPlayerBarViewController" bundle:nil];
    
//    [self.view addSubview:self.playerBar.view];
//    [self addingConstraintsForPlayerBar];
    self.playerControl = [[AVPlayer alloc] init];
    self.isPlaying = NO;
    self.isChangeTrack = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    //  -------------------------------------------
    //  create url with stream_url and client_id
    //  struct url from soundcloud: http://api.soundcloud.com/tracks/ + SOUNDCLOUD_TRACK_ID + /stream?client_id=YOUR_SOUNDCLOUD_API_KEY&filename=soundcloud.mp3
    //example: http://api.soundcloud.com/tracks/237316367/stream?client_id=e0d5195b63d3e78ad2422fa9871fe2b1&filename=soundcloud.mp3
    
    //    NSString *urlString = [NSString stringWithFormat:@"%@/TimEmDemGiangSinh.mp3",[[NSBundle mainBundle] resourcePath]];
    NSString *urlString = [NSString stringWithFormat:@"http://api.soundcloud.com/tracks/%@/stream?client_id=%@", self.track.ID, CLIENT_ID];
    NSURL *url = [NSURL URLWithString:urlString];
    if (self.isChangeTrack) {
        self.currentTrack = urlString;
        self.playerControl = nil;
        self.playerControl = [[AVPlayer alloc] initWithURL:url];
        self.isPlaying = YES;
    } else {
        
    }
    NSLog(@"%@", url);
    NSLog(@"%@", self.track.streamURL);
    
    self.playerControl.volume = 0.8;
    [self.playerControl play];
}

//#pragma mark - Adding constraints for playerBar
//
//- (void)addingConstraintsForPlayerBar {
//    self.playerBar.view.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    NSLayoutConstraint *barLeftConstraint = [NSLayoutConstraint constraintWithItem:self.playerBar.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f];
//    NSLayoutConstraint *barBottomConstraint = [NSLayoutConstraint constraintWithItem:self.playerBar.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
//    NSLayoutConstraint *barTopConstraint = [NSLayoutConstraint constraintWithItem:self.playerBar.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleTrack attribute: NSLayoutAttributeTop multiplier:1.0f constant:30];
//    NSLayoutConstraint *barRightConstraint = [NSLayoutConstraint constraintWithItem:self.playerBar.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute: NSLayoutAttributeRight multiplier:1.0f constant:0.0f];
//    
//    [NSLayoutConstraint activateConstraints:@[barLeftConstraint, barBottomConstraint, barTopConstraint, barRightConstraint]];
//}

#pragma mark - DropdownBarButton's event

- (void)dropDownBarButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Receive memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Playing music

- (IBAction)playPauseButtonClick:(id)sender {
    if (self.isPlaying) {
        [self.playPauseButton setSelected:YES];
        [self.playerControl pause];
        self.isPlaying = NO;
    } else {
        [self.playPauseButton setSelected:NO];
        [self.playerControl play];
        self.isPlaying = YES;
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
