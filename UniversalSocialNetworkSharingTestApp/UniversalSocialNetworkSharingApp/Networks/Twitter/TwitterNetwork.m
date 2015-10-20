//
//  TwitterNetwork.m
//  UniversalSharing
//
//  Created by Roman on 7/23/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//

#import "TwitterNetwork.h"
#import <TwitterKit/TwitterKit.h>
#import <Fabric/Fabric.h>
#import "MUSPlace.h"
#import "MUSLocation.h"
#import "NSError+MUSError.h"
#import "NSString+MUSPathToDocumentsdirectory.h"
#import "MUSInternetConnectionManager.h"
#import "MUSNetworkPost.h"
#import "NSString+MUSCurrentDate.h"
#import "MUSPostManager.h"
#import "MUSConstantsApp.h"
#import "MUSConstantsForParseSocialNetworkObjects.h"
#import "MUSConstantsForSocialNetworks.h"


@interface TwitterNetwork () //<TWTRCoreOAuthSigning>

@property (copy, nonatomic) Complition copyComplition;
@property (strong, nonatomic) NSArray *accountsArray;
@property (strong, nonatomic) ACAccount *twitterAccount;
@property (assign, nonatomic) BOOL doubleTouchFlag;
@property (copy, nonatomic) LoadingBlock loadingBlock;

@end

static TwitterNetwork *model = nil;

#pragma mark Singleton Method

@implementation TwitterNetwork
+ (TwitterNetwork*) sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[TwitterNetwork alloc] init];
    });
    return  model;
}

- (NSString *)icon {
    return MUSTwitterIconName;
}

- (NSString *)title {
    return self.isLogin ? [NSString stringWithFormat:@"%@ %@", self.currentUser.firstName, self.currentUser.lastName] : MUSTwitterTitle;
}

- (instancetype) init {
    self = [super init];
    self.doubleTouchFlag = NO;
    [TwitterKit startWithConsumerKey:MUSTwitterConsumerKey consumerSecret:MUSTwitterConsumerSecret];
    [Fabric with : @[TwitterKit]];
    if (self) {
        self.networkType = MUSTwitters;
        self.name = MUSTwitterName;
        if (![[Twitter sharedInstance ]session]) {
            [self initiationPropertiesWithoutSession];
        }
        else {
            [self initiationPropertiesWithSession];
            [self updateUserInSocialNetwork];
        }
    }
    return self;
}

/*!
 Initiation properties of TwitterNetwork without session
 */
- (void) initiationPropertiesWithoutSession {
    self.isLogin = NO;
}

/*!
 Initiation properties of TwitterNetwork with session
 */
- (void) initiationPropertiesWithSession {
    self.isLogin = YES;
}

#pragma mark - login
/*!
 Triggers user authentication with Twitter.
 This method will present UI to allow the user to log in if there are no saved Twitter login credentials.
 @param completion The completion block will be called after authentication is successful or if there is an error.
 */

- (void) loginWithComplition :(Complition) block {
    if (!self.doubleTouchFlag) {
        self.doubleTouchFlag = YES;
        __weak TwitterNetwork *weakSelf = self;
        
        [TwitterKit logInWithCompletion:^(TWTRSession* session, NSError* error) {
            if (session) {
                [weakSelf obtainUserInfoFromNetworkWithComplition:block];
            } else {
                block(nil, error);
            }
            weakSelf.doubleTouchFlag = NO;
        }];
    }
}

#pragma mark - logout

/*!
 Deletes the local Twitter user session from this app. This will not remove the system Twitter account and make a network request to invalidate the session.
 Current user for social network become nil
 And initiation properties of VKNetwork without session
 */

- (void) logout {
    
    [[Twitter sharedInstance] logOut];
    NSURL *url = [NSURL URLWithString: MUSTwitterURL_Api_Url];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    [[MUSPostManager manager] deleteNetworkPostForNetworkType: self.networkType];
    [self.currentUser removeUser];
    [self initiationPropertiesWithoutSession];
}


#pragma mark - obtainUserInfoFromNetwork

- (void) obtainUserInfoFromNetworkWithComplition :(Complition) block {
    __weak TwitterNetwork *weakSelf = self;
    
    [[TwitterKit APIClient] loadUserWithID : [[[Twitter sharedInstance ]session] userID]
                                 completion:^(TWTRUser *user, NSError *error)
     {
         if (user) {
             [weakSelf createUser: user];
             weakSelf.title = [NSString stringWithFormat:@"%@  %@", self.currentUser.firstName, self.currentUser.lastName];
             
             [weakSelf.currentUser insertIntoDataBase];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 weakSelf.isLogin = YES;
                 block(weakSelf,nil);
             });
        } else {
             block (nil, [self errorTwitter]);
         }
     }];
}

#pragma mark - sharePost

- (void) sharePost:(MUSPost *)post withComplition:(Complition)block loadingBlock: (LoadingBlock)loadingBlock {
    if (![[MUSInternetConnectionManager connectionManager] isInternetConnection]){
        MUSNetworkPost *networkPost = [MUSNetworkPost create];
        networkPost.networkType = MUSTwitters;
        block(networkPost,[self errorConnection]);
        loadingBlock ([NSNumber numberWithInteger: self.networkType], 1.0f);
        return;
    }
    self.loadingBlock = loadingBlock;
    self.copyComplition = block;
    if ([post.imagesArray count]) {
        [self sharePostWithPictures: post];
    } else {
        [self sharePostOnlyWithPostDescription: post];
    }
}

#pragma mark - sharePostOnlyWithPostDescription

/*!
 @abstract upload message and user location (optional)
 @param current post of @class Post
 */

- (void) sharePostOnlyWithPostDescription : (MUSPost*) post {
    __weak TwitterNetwork *weakSelf = self;
    TWTRAPIClient *client = [[Twitter sharedInstance] APIClient];
    NSError *error;
    
    NSString *url = MUSTwitterURL_Statuses_Update;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params [MUSTwitterParameter_Status] = [self checkPostsDescriptionOnTheMaximumNumberOfAllowedCharacters: post];
    if (post.longitude.length > 0 && ![post.longitude isEqualToString: @"(null)"] && post.latitude.length > 0 && ![post.latitude isEqualToString: @"(null)"]) {
        params [MUSTwitterLocationParameter_Latitude] = post.latitude;
        params [MUSTwitterLocationParameter_Longituge] = post.longitude;
    }
    
    NSURLRequest *preparedRequest = [client URLRequestWithMethod : MUSPOST
                                                             URL : url
                                                      parameters : params
                                                           error : &error];
    MUSNetworkPost *networkPost = [MUSNetworkPost create];
    networkPost.networkType = MUSTwitters;
    __block MUSNetworkPost* networkPostCopy = networkPost;
    
    [client sendTwitterRequest:preparedRequest
                    completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error){
            weakSelf.loadingBlock ([NSNumber numberWithInteger: self.networkType], 1.0f);
            
                if(!error){
                    NSError *jsonError = nil;
                    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&jsonError];
                    if (jsonError) {
                        //[self errorTwitter];
                        networkPostCopy.reason = MUSErrorConnection;
                        weakSelf.copyComplition (networkPostCopy, [self errorTwitter]);
                        return;
                    }
                    
                    networkPostCopy.postID = [[jsonData objectForKey:@"id"]stringValue];
                    networkPostCopy.reason = MUSConnect;
                    networkPostCopy.dateCreate = [NSString currentDate];
                    weakSelf.copyComplition (networkPostCopy, nil);
                }else{
                    networkPostCopy.reason = MUSErrorConnection;
                    weakSelf.copyComplition (networkPostCopy, [self errorTwitter]);
            }
    }];
}

#pragma mark - postMessageWithImageAndLocation

/*!
 @abstract upload image(s) with message (optional) and user location (optional)
 @param current post of @class Post
 */

- (void) sharePostWithPictures : (MUSPost*) post {
    __weak TwitterNetwork *weakSelf = self;
    MUSNetworkPost *networkPost = [MUSNetworkPost create];
    networkPost.networkType = MUSTwitters;
    __block MUSNetworkPost *networkPostCopy = networkPost;
    [self mediaIdsForTwitter : post withComplition:^(id result, NSError *error) {
        
        if (!error) {
            NSArray *mediaIdsArray = (NSArray*) result;
            NSString *mediaIdsString = [mediaIdsArray componentsJoinedByString:@","];
            NSString *endpoint = MUSTwitterURL_Statuses_Update;
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            
            params [MUSTwitterParameter_MediaID] = mediaIdsString;
        
            if (post.postDescription) {
                params [MUSTwitterParameter_Status] = [self checkPostsDescriptionOnTheMaximumNumberOfAllowedCharacters: post];
            }
            if (post.longitude.length > 0 && ![post.longitude isEqualToString: @"(null)"] && post.latitude.length > 0 && ![post.latitude isEqualToString: @"(null)"]) {
                params [MUSTwitterLocationParameter_Latitude] = post.latitude;
                params [MUSTwitterLocationParameter_Longituge] = post.longitude;
            }
            NSError *error = nil;
            
            TWTRAPIClient *client = [[Twitter sharedInstance] APIClient];
            NSURLRequest *request = [client URLRequestWithMethod: MUSPOST
                                                             URL: endpoint
                                                      parameters: params
                                                           error: &error];
            if (error) {
                networkPostCopy.reason = MUSErrorConnection;
                weakSelf.copyComplition (networkPostCopy, [self errorTwitter]);
                return;
            }
            [client sendTwitterRequest : request
                            completion : ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                weakSelf.loadingBlock ([NSNumber numberWithInteger: self.networkType], 1.0f);
                    if (!connectionError) {
                        NSError *jsonError = nil;
                        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                 options:NSJSONReadingMutableContainers
                                                                                   error:&jsonError];
                        if (jsonError) {
                            networkPostCopy.reason = MUSErrorConnection;
                            weakSelf.copyComplition (networkPostCopy, [self errorTwitter]);
                            return;
                        }
                        
                        networkPostCopy.postID = [[jsonData objectForKey:@"id"] stringValue];
                        networkPostCopy.reason = MUSConnect;
                        networkPost.dateCreate = [NSString currentDate];
                        weakSelf.copyComplition (networkPostCopy, nil);
                    } else {
                        NSError *connectionError = [NSError errorWithMessage: MUSConnectionError
                                                                andCodeError: MUSConnectionErrorCode];
                        networkPostCopy.reason = MUSErrorConnection;
                        weakSelf.copyComplition (networkPostCopy, connectionError);
                        return;
                                }
                            }];
        } else {
            networkPostCopy.reason = MUSErrorConnection;
            weakSelf.copyComplition (networkPostCopy, error);
            weakSelf.loadingBlock ([NSNumber numberWithInteger: self.networkType], 1.0f);
        }
    }];
}

/*!
 @abstract return a list of media IDs for Twitter Network to upload photos to social network
 @param current post of @class Post
 */

- (void) mediaIdsForTwitter : (MUSPost*) post withComplition : (Complition) block {
    NSMutableArray *mediaIdsArray = [[NSMutableArray alloc] init];
    __weak NSMutableArray *array = mediaIdsArray;
    __block NSInteger numberOfIds = post.imagesArray.count;
    __block int counterOfIds = 0;
    
    for (int i = 0; i < post.imagesArray.count; i++) {
        [self mediaIDForTwitter : [post.imagesArray objectAtIndex: i] withComplition:^(id result, NSError *error) {
            counterOfIds ++;
            if (!error) {
                [array addObject: result];
            }
            if (counterOfIds == numberOfIds) {
                if (!error) {
                    block (mediaIdsArray, nil);
                } else {
                    block (nil, [self errorTwitter]);
                }
            }
        }];
    }
}

/*!
 @abstract return the media IDs for each image is loaded into a social network
 @param current ImageToPost of @class ImageToPost
 */

- (void) mediaIDForTwitter : (MUSImageToPost*) imageToPost withComplition : (Complition) block {
    NSString *endpoint = MUSTwitterURL_Media_Upload;
    NSData* imageData = UIImageJPEGRepresentation(imageToPost.image, imageToPost.quality);
    NSDictionary *parameters = @{ MUSTwitterParameter_Media : [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed ]};
    NSError *error = nil;
    
    TWTRAPIClient *client = [[Twitter sharedInstance] APIClient];
    NSURLRequest *request = [client URLRequestWithMethod : MUSPOST
                                                     URL : endpoint
                                              parameters : parameters
                                                   error : &error];
    if (error) {
        block (nil, [self errorTwitter]);
        return;
    }
    [client sendTwitterRequest : request
                    completion : ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *jsonError = nil;
            id jsonData = [NSJSONSerialization JSONObjectWithData : data
                                                          options : NSJSONReadingMutableContainers
                                                            error : &jsonError];
            if (jsonError) {
                block (nil, [self errorTwitter]);
                return;
            }
            
            NSString *mediaId = jsonData [MUSTwitterJSONParameterForMediaID];
            block (mediaId, nil);
        } else {
            NSError *connectionError = [NSError errorWithMessage : MUSConnectionError
                                                    andCodeError : MUSConnectionErrorCode];
            block (nil, connectionError);
            return;
        }
    }];
}


#pragma mark - obtainPlacesArrayForLocation

- (void) obtainPlacesArrayForLocation : (MUSLocation*) location withComplition : (Complition) block {
    self.copyComplition = block;
    __weak TwitterNetwork *weakSelf = self;
    TWTRAPIClient *client = [[Twitter sharedInstance] APIClient];
    NSError *error;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (!location.latitude || !location.longitude || [location.latitude floatValue] < -90.0f || [location.latitude floatValue] > 90.0f || [location.longitude floatValue] < -180.0f  || [location.longitude floatValue] > 180.0f) {
        
        NSError *error = [NSError errorWithMessage: MUSLocationPropertiesError
                                      andCodeError: MUSLocationPropertiesErrorCode];
        return block (nil, error);
    } else {
        params [MUSTwitterLocationParameter_Latitude] = location.latitude;
        params [MUSTwitterLocationParameter_Longituge] = location.longitude;
    }
    
    NSString *url = MUSTwitterURL_Geo_Search;
    NSURLRequest *preparedRequest = [client URLRequestWithMethod : MUSGET
                                                             URL : url
                                                      parameters : params
                                                           error : &error];
    
    [client sendTwitterRequest : preparedRequest
                     completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error){
                         
        if(!error){
            NSError *jsonError;
            NSDictionary *locationJSON = [NSJSONSerialization JSONObjectWithData : responseData
                                                                         options : 0
                                                                           error : &jsonError];
                             
            NSDictionary *resultSearcLocation = [locationJSON objectForKey: MUSTwitterParseLocation_Result];
            NSArray *places = [resultSearcLocation objectForKey: MUSTwitterParseLocation_Places];
            NSMutableArray *placesArray = [[NSMutableArray alloc] init];
                             
            for (int i = 0; i < [places count]; i++) {
                MUSPlace *place = [weakSelf createPlace: [places objectAtIndex: i]];
                [placesArray addObject:place];
            }
                             
            if ([placesArray count] != 0) {
                block (placesArray, nil);
            } else {
                NSError *error = [NSError errorWithMessage: MUSLocationDistanceError andCodeError: MUSLocationDistanceErrorCode];
                block (nil, error);
            }
        }else{
            block (nil, [weakSelf errorTwitter]);
        }
    }];
}

#pragma mark - updateNetworkPostWithComplition

- (void) updateNetworkPostWithComplition: (UpdateNetworkPostsBlock) updateNetworkPostsBlock {
    NSArray * networksPostsIDs = [[MUSPostManager manager] networkPostsArrayForNetworkType: self.networkType];
    
    if (![[MUSInternetConnectionManager connectionManager] isInternetConnection] || !networksPostsIDs.count || (![[MUSInternetConnectionManager connectionManager] isInternetConnection] && networksPostsIDs.count)) {
        updateNetworkPostsBlock (MUSTwitterError);
        return;
    }

    __block NSUInteger counterOfNetworkPosts = 0;
    __block NSUInteger numberOfNetworkPosts = networksPostsIDs.count;
    
    [networksPostsIDs enumerateObjectsUsingBlock:^(MUSNetworkPost *networkPost, NSUInteger idx, BOOL *stop) {
        [self obtainCountOfLikesAndCommentsFromPost: networkPost withComplition:^(id result, NSError *error) {
            counterOfNetworkPosts++;
            if (counterOfNetworkPosts == numberOfNetworkPosts) {
                updateNetworkPostsBlock (MUSTwitterSuccessUpdateNetworkPost);
            }
        }];
    }];
}

- (void) obtainCountOfLikesAndCommentsFromPost :(MUSNetworkPost*) networkPost withComplition : (Complition) block {
    NSString *statusesShowEndpoint = MUSTwitterURL_Statuses_Show;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys : networkPost.postID, MUSTwitterParameter_ID, MUSTwitterParameter_True, MUSTwitterParameter_Include_My_Retweet, nil];
    
    NSError *clientError;
    
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod: MUSGET
                                                                                   URL:statusesShowEndpoint
                                                                            parameters:params
                                                                                 error:&clientError];
    __block MUSNetworkPost *networkPostCopy = networkPost;
    
    if (request) {
        [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSError *jsonError;
                NSDictionary *arrayJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (!arrayJson.count) {
                    block (MUSNetworkPost_Update_Error_Data, nil);
                    return;
                }
                if (networkPostCopy.likesCount == [[arrayJson  objectForKey:MUSTwitterParameter_Favorite_Count] integerValue] &&  networkPostCopy.commentsCount == [[arrayJson  objectForKey:MUSTwitterParameter_Retweet_Count] integerValue] ) {
                    block (MUSNetworkPost_Update_Already_Update, nil);
                    return;
                }
                
                networkPostCopy.likesCount = [[arrayJson  objectForKey:MUSTwitterParameter_Favorite_Count] integerValue];
                networkPostCopy.commentsCount = [[arrayJson objectForKey:MUSTwitterParameter_Retweet_Count] integerValue];
                [networkPostCopy update];
                block (MUSNetworkPost_Update_Updated, nil);
            }
            else {
                block (connectionError, nil);
            }
        }];
    }
    else {
        block (MUSNetworkPost_Update_Error_Update, nil);
    }
}

/*!
 @abstract returned Twitter network error
 */
- (NSError*) errorTwitter {
    return [NSError errorWithMessage: MUSTwitterError andCodeError: MUSTwitterErrorCode];
}

#pragma mark - createUser
/*!
 @abstract an instance of the User for twitter network.
 @param dictionary takes dictionary from twitter network.
 */
- (void) createUser : (TWTRUser*) userDictionary {
    if (!self.currentUser) {
        self.currentUser = [MUSUser create];
    }
    
    self.currentUser.clientID = userDictionary.userID;
    self.currentUser.lastName = userDictionary.screenName;
    self.currentUser.firstName = userDictionary.name;
    self.currentUser.networkType = MUSTwitters;
    NSString *photoURL_max = userDictionary.profileImageURL;
    photoURL_max = [photoURL_max stringByReplacingOccurrencesOfString:@"_normal"
                                                           withString:@""];
    self.currentUser.photoURL = photoURL_max;
    self.currentUser.photoURL = [self.currentUser.photoURL saveImageOfUserToDocumentsFolder: self.currentUser.photoURL];
}



- (NSString*) checkPostsDescriptionOnTheMaximumNumberOfAllowedCharacters : (MUSPost*) post {
    NSString* messageText = post.postDescription;
    
    if (post.postDescription.length > MUSApp_TextView_Twitter_NumberOfAllowedLetters) {
        messageText = [post.postDescription substringToIndex: MUSApp_TextView_Twitter_NumberOfAllowedLetters];
    }
    return messageText;
}

#pragma mark - createPlace

/*!
 @abstract an instance of the Place for twitter network.
 @param dictionary takes dictionary from twitter network.
 */
- (MUSPlace*) createPlace : (NSDictionary *) dictionary {
    MUSPlace *currentPlace = [MUSPlace create];
    
    currentPlace.placeID   = [dictionary objectForKey: MUSTwitterParsePlace_ID];
    currentPlace.placeType = [dictionary objectForKey: MUSTwitterParsePlace_Place_Type];
    currentPlace.country   = [dictionary objectForKey: MUSTwitterParsePlace_Country];
    currentPlace.fullName  = [dictionary objectForKey: MUSTwitterParsePlace_Full_Name];
    
    NSArray *centroid = [dictionary objectForKey: MUSTwitterParsePlace_Centroid];
    currentPlace.latitude = [NSString stringWithFormat: @"%@", [centroid lastObject]];
    currentPlace.longitude = [NSString stringWithFormat: @"%@", [centroid firstObject]];
    
    NSArray *containedWithinArray = [dictionary objectForKey: MUSTwitterParsePlace_Contained_Within];
    NSDictionary *locationTwitterDictionary = [containedWithinArray firstObject];
    currentPlace.city = [locationTwitterDictionary objectForKey: MUSTwitterParsePlace_Name];
    
    return currentPlace;
}


@end
