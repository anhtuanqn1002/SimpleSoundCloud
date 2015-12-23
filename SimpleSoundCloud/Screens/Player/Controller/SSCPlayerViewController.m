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
    
    playerBar.view.frame = CGRectMake(0, 400, 800, 200);
    NSLayoutConstraint *leftBarXConstraint = [NSLayoutConstraint constraintWithItem:playerBar.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:0.5f constant:10.0f];
    NSLayoutConstraint *leftBarYConstraint = [NSLayoutConstraint constraintWithItem:playerBar.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-20.0f];
//    NSLayoutConstraint *leftBarTopConstraint = [NSLayoutConstraint constraintWithItem:playerBar.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.playerSlider attribute: NSLayoutAttributeTop multiplier:1.0f constant:-30.0f];
    
//    [playerBar.view addConstraint:[NSLayoutConstraint constraintWithItem:playerBar.view
//                                                     attribute:NSLayoutAttributeWidth
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.view
//                                                     attribute:NSLayoutAttributeWidth
//                                                    multiplier:0.5
//                                                      constant:0]];
//    [playerBar.view addConstraint:[NSLayoutConstraint constraintWithItem:playerBar.view
//                                                     attribute:NSLayoutAttributeHeight
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.view
//                                                     attribute:NSLayoutAttributeHeight
//                                                    multiplier:0.5
//                                                      constant:0]];
//    
//    // Center horizontally
//    [playerBar.view addConstraint:[NSLayoutConstraint constraintWithItem:playerBar.view
//                                                     attribute:NSLayoutAttributeCenterX
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.view
//                                                     attribute:NSLayoutAttributeCenterX
//                                                    multiplier:1.0
//                                                      constant:0.0]];
//    
//    // Center vertically
//    [playerBar.view addConstraint:[NSLayoutConstraint constraintWithItem:playerBar.view
//                                                     attribute:NSLayoutAttributeCenterY
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.view
//                                                     attribute:NSLayoutAttributeCenterY
//                                                    multiplier:1.0
//                                                      constant:0.0]];
//    [self.view setNeedsDisplay];
    [self.view addConstraints:@[leftBarXConstraint, leftBarYConstraint]];
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
