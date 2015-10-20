//
//  MultiSharingManager.h
//  UniversalSharing
//
//  Created by U 2 on 25.09.15.
//  Copyright (c) 2015 Mobindustry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUSSocialNetworkLibraryConstants.h"
#import "MUSPost.h"

typedef void (^StartLoadingBlock)(MUSPost *post);
typedef void (^MultiSharingResultBlock)(NSDictionary *multiResultDictionary, MUSPost *post);


@interface MUSMultiSharingManager : NSObject

+ (MUSMultiSharingManager*) sharedManager;

- (void) sharePost : (MUSPost*) post toSocialNetworks : (NSArray*) networksTypesArray withMultiSharingResultBlock : (MultiSharingResultBlock) multiSharingResultBlock startLoadingBlock : (StartLoadingBlock) startLoadingBlock progressLoadingBlock :(ProgressLoadingBlock) progressLoadingBlock;

- (BOOL) isQueueContainsPost : (NSInteger) primaryKeyOfPost;


@end
