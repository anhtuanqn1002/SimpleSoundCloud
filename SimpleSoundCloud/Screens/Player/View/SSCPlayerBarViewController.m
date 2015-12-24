//
//  PlayerBarViewController.m
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/22/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import "SSCPlayerBarViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface SSCPlayerBarViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loopButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *rewardButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (strong, nonatomic) AVPlayer *playerControl;
@property (strong, nonatomic) NSURL *url;
@end

@implementation SSCPlayerBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

#pragma mark - Event to click button

- (IBAction)clickPlayButton:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        NSLog(@"button click");
    } else {
        self.url = sender;
        self.playerControl = [[AVPlayer alloc] initWithURL:self.url];
    }
    if (self.playButton.isSelected) {
        [self.playButton setSelected:NO];
        [self.playerControl pause];
    } else {
        [self.playButton setSelected:YES];
        self.playerControl.volume = 0.8;
        [self.playerControl play];
    }
}
- (IBAction)clickShuffleButton:(id)sender {
}
- (IBAction)clickRewardButton:(id)sender {
}
- (IBAction)clickForwardButton:(id)sender {
}
- (IBAction)clickLoopButton:(id)sender {
}

#pragma mark - Playing music

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
