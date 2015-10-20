//
//  MUSToolBarForDetailCollectionView.m
//  UniversalSharing
//
//  Created by Roman on 9/18/15.
//  Copyright (c) 2015 Mobindustry. All rights reserved.
//

#import "MUSToolBarForMediaGalleryViewController.h"
#import "MUSConstantsApp.h"

@interface MUSToolBarForMediaGalleryViewController()

@property (strong, nonatomic) UIView *view;

@end
@implementation MUSToolBarForMediaGalleryViewController

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self xibSetup];
    }
    return self;
}

-(id) initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self xibSetup];
    }
    return self;
}

- (void) xibSetup {    
    self.view = [self loadViewFromNib];
    self.view.frame = self.bounds;
    [self addSubview:self.view];
    
}

-(UIView*)loadViewFromNib {
    NSArray *nibObjects = [[NSBundle mainBundle]loadNibNamed:MUSApp_MUSToolBarForMediaGalleryViewController_NibName owner:self options:nil];
    return [nibObjects firstObject];
}

- (void) awakeFromNib {
    
    
}


@end