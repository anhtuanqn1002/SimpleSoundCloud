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
#import "UIImageView+WebCache.h"

#define CLIENT_ID @"e0d5195b63d3e78ad2422fa9871fe2b1"

@interface SSCPlayerViewController ()

//do not use AVAudioPlayer because that is not playing a stream (only offline file)
@property (strong, nonatomic) AVPlayer *playerControl;

@property (weak, nonatomic) IBOutlet UIImageView *avatarPlayer;
@property (weak, nonatomic) IBOutlet UISlider *playerSlider;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleTrack;

@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *rewardButton;
@property (weak, nonatomic) IBOutlet UIButton *loopButton;

@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) NSString *currentTrackName;
@property (assign, nonatomic) BOOL isShow;

@end

@implementation SSCPlayerViewController

#pragma mark - Share Instance

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
    
    //  -------Start screen------------------------
    [self startPlayerViewController];
    
    //  -------------------------------------------
    //  turn on Player Screen notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TURN_ON_PLAYER" object:nil];
    
    NSLog(@"Number of playlist: %ld", [self.listTrack count]);
}

#pragma mark - Start screen

- (void)startPlayerViewController {
    
    //  -------------------------------------------
    //  init avplayer
    self.playerControl = [[AVPlayer alloc] init];
    self.isPlaying = YES;
    [self.playPauseButton setSelected:YES];
    self.isChangeTrack = YES;
    
    //  slider change value
    [self.playerSlider addTarget:self action:@selector(playerSliderChangeValue:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - viewDidAppear

- (void)viewDidAppear:(BOOL)animated {
    [self playingNewTrack:YES];
}

#pragma mark - Play new track

- (void)playingNewTrack:(BOOL)isPlay {
    //  -------------------------------------------
    //  create url with stream_url and client_id
    //  struct url from soundcloud: http://api.soundcloud.com/tracks/ + SOUNDCLOUD_TRACK_ID + /stream?client_id=YOUR_SOUNDCLOUD_API_KEY&filename=soundcloud.mp3
    //example: http://api.soundcloud.com/tracks/237316367/stream?client_id=e0d5195b63d3e78ad2422fa9871fe2b1&filename=soundcloud.mp3
    
    //    NSString *urlString = [NSString stringWithFormat:@"%@/TimEmDemGiangSinh.mp3",[[NSBundle mainBundle] resourcePath]];
    NSString *urlString = [NSString stringWithFormat:@"http://api.soundcloud.com/tracks/%@/stream?client_id=%@", self.currentTrack.ID, CLIENT_ID];
    NSURL *url = [NSURL URLWithString:urlString];
    if (self.isChangeTrack) {
        self.currentTrackName = urlString;
        self.playerControl = nil;
        self.playerControl = [[AVPlayer alloc] initWithURL:url];
        self.isPlaying = isPlay;
    } else {
        
    }
    NSLog(@"%@", url);
    NSLog(@"%@", self.currentTrack.streamURL);
    //    -------------------------------------------------
    //    setup player control
    //    duration.value/duration.timescale = second
    self.playerSlider.maximumValue = self.playerControl.currentItem.asset.duration.value/self.playerControl.currentItem.asset.duration.timescale;
    self.playerControl.volume = 0.8;
    
    if (self.isPlaying) {
        [self.playerControl play];
    } else {
        [self.playerControl pause];
    }
    
    //  -------setup screen------------------------
    [self setupScreen];
    
    __weak typeof(self) weakself = self;
    //  -------------------------------------------
    //  player process bar
    [self.playerControl addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        weakself.playerSlider.value = weakself.playerControl.currentTime.value/weakself.playerControl.currentTime.timescale;
        NSInteger durationSeconds = weakself.playerControl.currentTime.value/weakself.playerControl.currentTime.timescale;
        NSInteger minutes = floor(durationSeconds % 3600 / 60);
        NSInteger seconds = floor(durationSeconds % 3600 % 60);
        weakself.startLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
        
        //--------------if currenttime == duration
        // then stop currenttrack and next track
        if (weakself.playerControl.currentTime.value == weakself.playerControl.currentItem.asset.duration.value) {
            NSLog(@"end current track --> next track");
            [weakself forwardButtonClick:nil];
        }
    }];
}

#pragma mark - Setup screen

- (void)setupScreen {
    
    //  --------------------------------------------
    //  set all label when playing new track
    self.playerSlider.value = self.playerControl.currentTime.value/self.playerControl.currentTime.timescale;
    self.titleTrack.text = self.currentTrack.trackTitle;
    
    NSInteger startDurationSeconds = self.playerControl.currentTime.value/self.playerControl.currentTime.timescale;
    NSInteger startMinutes = floor(startDurationSeconds % 3600 / 60);
    NSInteger startSeconds = floor(startDurationSeconds % 3600 % 60);
    self.startLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", startMinutes, startSeconds];
    
    NSInteger durationSeconds = self.playerControl.currentItem.asset.duration.value/self.playerControl.currentItem.asset.duration.timescale;
    NSInteger minutes = floor(durationSeconds % 3600 / 60);
    NSInteger seconds = floor(durationSeconds % 3600 % 60);
    self.endLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
    
    //  --------------Setup avatar image
    [self.avatarPlayer sd_setImageWithURL:[NSURL URLWithString:self.currentTrack.artworkURL] placeholderImage:[UIImage imageNamed:@"icon_artwork_default.png"]];
}

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
        [self.playPauseButton setSelected:NO];
        [self.playerControl pause];
        self.isPlaying = NO;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"TURN_OFF_PLAYER" object:nil];
    } else {
        [self.playPauseButton setSelected:YES];
        [self.playerControl play];
        self.isPlaying = YES;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"TURN_ON_PLAYER" object:nil];
    }
}

- (IBAction)forwardButtonClick:(id)sender {
    NSInteger index = [self.listTrack indexOfObject:self.currentTrack];
    if (index == [self.listTrack count] - 1) {
        self.currentTrack = [self.listTrack firstObject];
    } else {
        self.currentTrack = [self.listTrack objectAtIndex:index+1];
    }
    if (self.isPlaying) {
        [self playingNewTrack:YES];
    } else {
        [self playingNewTrack:NO];
    }
}

- (IBAction)rewardButtonClick:(id)sender {
    NSInteger index = [self.listTrack indexOfObject:self.currentTrack];
    if (index == 0) {
        self.currentTrack = [self.listTrack lastObject];
    } else {
        self.currentTrack = [self.listTrack objectAtIndex:index-1];
    }
    
    if (self.isPlaying) {
        [self playingNewTrack:YES];
    } else {
        [self playingNewTrack:NO];
    }
}

- (IBAction)loopButtonClick:(id)sender {
    if (self.loopButton.state == UIControlStateNormal) {
        self.loopButton.highlighted = YES;
//        self.loopButton 
    } else if (self.loopButton.state == UIControlStateHighlighted) {
        self.loopButton.selected = YES;
    }
}

- (IBAction)shuffleButtonClick:(id)sender {
}

#pragma mark - Player silder change value

- (void)playerSliderChangeValue:(id)sender {
    NSLog(@"%f", self.playerSlider.value);
    CMTime cmTime = CMTimeMake(self.playerSlider.value, 1);
    [self.playerControl seekToTime:cmTime];
    [self.playerControl play];
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
