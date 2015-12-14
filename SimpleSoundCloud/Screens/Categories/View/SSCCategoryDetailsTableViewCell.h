//
//  TrackTableViewCell.h
//  SimpleSoundCloud
//
//  Created by Nguyen Van Anh Tuan on 12/8/15.
//  Copyright © 2015 Nguyen Van Anh Tuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSCCategoryDetailsTableViewCellDelegate <NSObject>

- (void)changeStateButtonAddTrack:(BOOL)state sender:(id)sender;

@end

@interface SSCCategoryDetailsTableViewCell : UITableViewCell

- (void)setupViewCellWithArtWork:(NSString *)artwork andTrackName:(NSString *)trackname andTrackLike:(NSInteger)tracklike andTrackPlay:(NSInteger)trackplay andTrackAdd:(BOOL)trackadd withCellType:(NSInteger)cellType;
- (void)setSelectedAddButton:(BOOL)state;
@property (nonatomic, weak) id <SSCCategoryDetailsTableViewCellDelegate> delegate;

@end
