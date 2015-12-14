//
//  TrackTableViewCell.m
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/8/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import "SSCCategoryDetailsTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface SSCCategoryDetailsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *trackArtWork;
@property (weak, nonatomic) IBOutlet UILabel *trackName;
@property (weak, nonatomic) IBOutlet UILabel *trackLike;
@property (weak, nonatomic) IBOutlet UILabel *trackPlay;
@property (weak, nonatomic) IBOutlet UIButton *trackAdd;


@end


@implementation SSCCategoryDetailsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupViewCellWithArtWork:(NSString *)artwork andTrackName:(NSString *)trackname andTrackLike:(NSInteger)tracklike andTrackPlay:(NSInteger)trackplay andTrackAdd:(BOOL)trackadd withCellType:(NSInteger)cellType{
//    [self.trackArtWork setImage:[UIImage imageNamed:artwork]];
    [self.trackArtWork sd_setImageWithURL:[NSURL URLWithString:artwork] placeholderImage:[UIImage imageNamed:@"icon_artwork_default.png"]];
    [self.trackName setText:trackname];
    [self.trackLike setText:[NSString stringWithFormat:@"%ld", tracklike]];
    [self.trackPlay setText:[NSString stringWithFormat:@"%ld", trackplay]];
    [self.trackAdd setSelected:trackadd];
    if (cellType != 0) {
        [self.trackAdd setHidden:YES];
    }
}

- (void)setSelectedAddButton:(BOOL)state {
    [self.trackAdd setSelected:state];
}

- (IBAction)trackAddClicked:(id)sender {
    if (!self.trackAdd.selected) {
        [self.trackAdd setSelected:YES];
        [self.delegate changeStateButtonAddTrack:self.trackAdd.selected sender:self];
    }
}

@end
