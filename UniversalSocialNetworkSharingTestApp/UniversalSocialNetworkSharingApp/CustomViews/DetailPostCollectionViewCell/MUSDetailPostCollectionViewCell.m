//
//  MUSDetailPostCollectionViewCell.m
//  UniversalSharing
//
//  Created by U 2 on 31.08.15.
//  Copyright (c) 2015 Mobindustry. All rights reserved.
//

#import "MUSDetailPostCollectionViewCell.h"

@interface MUSDetailPostCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation MUSDetailPostCollectionViewCell

+ (NSString*) customCellID {
    return NSStringFromClass([MUSDetailPostCollectionViewCell class]);
}

+ (instancetype) musDetailPostCollectionViewCell {
    NSArray* nibArray = [[NSBundle mainBundle]loadNibNamed:[self customCellID] owner:nil options:nil];
    return nibArray[0];
}

- (NSString *)reuseIdentifier{
    return [MUSDetailPostCollectionViewCell customCellID];
}

- (void) configurationCellWithPhoto: (UIImage*) photoImageView {
    self.photoImageView.image = photoImageView;
}

@end
