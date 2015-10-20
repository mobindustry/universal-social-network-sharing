//
//  MultiSharingManager.m
//  UniversalSharing
//
//  Created by U 2 on 25.09.15.
//  Copyright (c) 2015 Mobindustry. All rights reserved.
//

#import "MUSMultiSharingManager.h"
#import "MUSSocialNetwork.h"
#import "MUSDataBaseManager.h"
#import "MUSDatabaseRequestStringsHelper.h"
#import "MUSPostImagesManager.h"
#import "MUSSocialManager.h"
#import "MUSPostManager.h"
#import "MUSProgressBar.h"
#import "MUSProgressBarEndLoading.h"

@interface MUSMultiSharingManager ()

@property (copy, nonatomic) MultiSharingResultBlock multiSharingResultBlock;
@property (copy, nonatomic) ProgressLoadingBlock progressLoadingBlock;
@property (copy, nonatomic) StartLoadingBlock startLoadingBlock;
@property (assign, nonatomic) BOOL isPostLoading;
@property (strong, nonatomic) NSMutableArray *postsQueue;

@end


static MUSMultiSharingManager *model = nil;


@implementation MUSMultiSharingManager

+ (MUSMultiSharingManager*) sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[MUSMultiSharingManager alloc] init];
    });
    return  model;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        if (!self.postsQueue) {
            self.postsQueue = [[NSMutableArray alloc] init];
            self.isPostLoading = NO;
        }
    }
    return self;
}


- (void) sharePost : (MUSPost*) post toSocialNetworks : (NSArray*) networksTypesArray withMultiSharingResultBlock : (MultiSharingResultBlock) multiSharingResultBlock startLoadingBlock : (StartLoadingBlock) startLoadingBlock progressLoadingBlock :(ProgressLoadingBlock) progressLoadingBlock {
    
    NSMutableArray *arrayWithNetworks = [[MUSSocialManager sharedManager]networksForKeys:networksTypesArray];
    
    self.multiSharingResultBlock = multiSharingResultBlock;
    self.progressLoadingBlock = progressLoadingBlock;
    self.startLoadingBlock = startLoadingBlock;
    
    NSDictionary *postDictionary = [NSDictionary
                                    dictionaryWithObjectsAndKeys: [post copy], @"post",
                                    arrayWithNetworks, @"arrayWithNetworks", nil];
    
    [self.postsQueue addObject: postDictionary];
    
    if (!self.isPostLoading) {
        NSDictionary *firstPostDictionary = [self.postsQueue firstObject];
        [self sharePostDictionary: firstPostDictionary];
    }
}

- (void) sharePostDictionary: (NSDictionary*) postDictionary {
    MUSPost *currentPost =  [postDictionary objectForKey: @"post"];
    self.startLoadingBlock (currentPost);
    [self sharePost: currentPost toSocialNetworks: [postDictionary objectForKey: @"arrayWithNetworks"]];
}

- (void) sharePost : (MUSPost*) post toSocialNetworks : (NSArray*) arrayWithNetworks {
    __block NSMutableDictionary *loadingObjectsDictionary = [self dictionaryOfLoadingObjectsFromNetworks: arrayWithNetworks];
    
    self.isPostLoading = YES;
    
    if (!post.primaryKey) {
        post.networkPostIdsArray = [NSMutableArray new];
    }
    
    __block MUSPost *postCopy = post;
    __block NSUInteger numberOfSocialNetworks = arrayWithNetworks.count;
    __block int counterOfSocialNetwork = 0;
    __weak MUSMultiSharingManager *weakMultiSharingManager = self;

    __block NSMutableDictionary *multiResultDictionary = [[NSMutableDictionary alloc] init];
    
    for (MUSSocialNetwork *socialNetwork in arrayWithNetworks) {
        [socialNetwork sharePost: post withComplition:^(id result, NSError *error) {

            counterOfSocialNetwork++;
            
            MUSNetworkPost *networkPost;
            
            if ([result isKindOfClass: [MUSNetworkPost class]]) {
                networkPost = (MUSNetworkPost*) result;
                
                NSDictionary* resultDictionary = @{
                                          @"Result" : [NSNumber numberWithInt: networkPost.reason],
                                           @"Error" : error ? error : [NSNull null]
                                          };
                [multiResultDictionary setObject: resultDictionary forKey: @(networkPost.networkType)];
                
                if (!postCopy.primaryKey) {
                    [postCopy.networkPostIdsArray addObject: [NSString stringWithFormat: @"%ld", (long)[[MUSDataBaseManager sharedManager] saveNetworkPost: networkPost]]];
                } else {
                    [weakMultiSharingManager updateCurrentNetworkPost: networkPost andArrayOfOldNetworkPosts: postCopy.networkPostsArray];
                }
            }

            if (counterOfSocialNetwork == numberOfSocialNetworks) {
                if (!postCopy.primaryKey) {
                    [postCopy saveIntoDataBase];
                }
                weakMultiSharingManager.multiSharingResultBlock (multiResultDictionary, postCopy);
                [weakMultiSharingManager checkPostsQueue];
            }

        } loadingBlock : ^(id currentNetworkType, float result) {
            
            float totalProgress = [weakMultiSharingManager totalResultOfLoadingToSocialNetworks: loadingObjectsDictionary withCurrentObject: currentNetworkType andResult: result];
            weakMultiSharingManager.progressLoadingBlock (totalProgress / numberOfSocialNetworks);
            NSLog(@"%f", totalProgress / numberOfSocialNetworks);
        }];
    }
}


- (void) updateCurrentNetworkPost : (MUSNetworkPost*) newNetworkPost andArrayOfOldNetworkPosts : (NSMutableArray*) arrayOfOldPosts {
    
    for (MUSNetworkPost *currentNetworkPost in arrayOfOldPosts) {
        [currentNetworkPost updateByNewNetworkPost: newNetworkPost];
    }
    
}

- (void) checkPostsQueue {
    [self.postsQueue removeObjectAtIndex: 0];
    if (self.postsQueue.count > 0) {
        NSDictionary *postDictionary = [self.postsQueue firstObject];
        [self sharePostDictionary: postDictionary];
    } else {
        self.isPostLoading = NO;
    }
}

- (BOOL) isQueueContainsPost: (NSInteger)primaryKeyOfPost {
    for (NSDictionary *dictionary in self.postsQueue) {
        MUSPost *currentPost = [dictionary objectForKey: @"post"];
        if (currentPost.primaryKey == primaryKeyOfPost) {
            return YES;
        }
    }
    return NO;
}

- (NSMutableDictionary*) dictionaryOfLoadingObjectsFromNetworks : (NSArray*) arrayWithNetworks {
    NSMutableDictionary *loadingObjectsDictionary = [[NSMutableDictionary alloc] init];
    
    for (MUSSocialNetwork *socialNetwork in arrayWithNetworks) {
        [loadingObjectsDictionary setObject: [NSNumber numberWithFloat: 0.000001] forKey: [NSNumber numberWithInt: socialNetwork.networkType]];
    }
    
    return loadingObjectsDictionary;
}

- (float) totalResultOfLoadingToSocialNetworks : (NSMutableDictionary*) loadingObjectsDictionary withCurrentObject : (NSNumber*) currentNetworkType andResult : (float) result {

    [loadingObjectsDictionary setObject:[NSNumber numberWithFloat: result] forKey: currentNetworkType];
    
    NSArray *allValues = [loadingObjectsDictionary allValues];
    NSNumber *sum = [allValues valueForKeyPath: @"@sum.self"];

    return [sum floatValue];
}

@end
