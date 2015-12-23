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

@interface SSCPlayerViewController ()

@property (strong, nonatomic) AVAudioPlayer *playerControl;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *dropPlayerButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarPlayer;
@property (weak, nonatomic) IBOutlet UISlider *playerSlider;

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
    NSString *urlString = [NSString stringWithFormat:@"%@/TimEmDemGiangSinh.mp3",[[NSBundle mainBundle] resourcePath]];
    NSURL *url = [NSURL fileURLWithPath:urlString];
    self.playerControl = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.playerControl.volume = 0.8;
    
    SSCPlayerBarViewController *playerBar = [[SSCPlayerBarViewController alloc] initWithNibName:@"SSCPlayerBarViewController" bundle:nil];
    [self.view addSubview:playerBar.view];
    
    playerBar.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *barLeftConstraint = [NSLayoutConstraint constraintWithItem:playerBar.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *barBottomConstraint = [NSLayoutConstraint constraintWithItem:playerBar.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *barTopConstraint = [NSLayoutConstraint constraintWithItem:playerBar.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.playerSlider attribute: NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *barRightConstraint = [NSLayoutConstraint constraintWithItem:playerBar.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute: NSLayoutAttributeRight multiplier:1.0f constant:0.0f];
    
    [NSLayoutConstraint activateConstraints:@[barLeftConstraint, barBottomConstraint, barTopConstraint, barRightConstraint]];
//    [self.view addConstraints:@[leftBarXConstraint, leftBarYConstraint, leftBarTopConstraint, leftBarRightConstraint]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickDropPlayerButton:(id)sender {
    [self.playerControl play];
    [self dismissViewControllerAnimated:YES completion:nil];
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
