//
//  MUSLocationManager.h
//  UniversalSharing
//
//  Created by U 2 on 28.07.15.
//  Copyright (c) 2015 Mobindustry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MUSConstantsApp.h"

@interface MUSLocationManager : NSObject

+ (MUSLocationManager*) sharedManager;
//===
- (void) startTrackLocationWithComplition : (Complition) block;
- (void) obtainAddressFromLocation:(CLLocation *)location complitionBlock: (Complition) block;

@end
