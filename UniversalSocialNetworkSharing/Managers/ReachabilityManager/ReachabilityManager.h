//
//  ReachabilityManager.h
//  UniversalSharing
//
//  Created by U 2 on 07.08.15.
//  Copyright (c) 2015 Mobindustry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface ReachabilityManager : NSObject

@property (strong, nonatomic) Reachability *reachability;

+ (ReachabilityManager *)sharedManager;
+ (BOOL)isReachable;
+ (BOOL)isUnreachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

@end
