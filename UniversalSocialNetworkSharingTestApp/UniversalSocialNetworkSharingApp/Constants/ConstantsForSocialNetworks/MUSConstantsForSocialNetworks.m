//
//  MUSConstantsForSocialNetworks.m
//  UniversalSharing
//
//  Created by U 2 on 15.10.15.
//  Copyright © 2015 Mobindustry. All rights reserved.
//

#import "MUSConstantsForSocialNetworks.h"

#pragma mark Facebook Constants

NSString *const MUSFacebookTitle = @"Login Facebook";
NSString *const MUSFacebookIconName = @"Facebook_Icon.png";
NSString *const MUSFacebookName = @"Facebook";

NSString *const MUSFacebookPermission_Email = @"email";
NSString *const MUSFacebookPermission_Publish_Actions = @"publish_actions";

NSString *const MUSFacebookGraphPath_Me = @"/me";
NSString *const MUSFacebookGraphPath_Me_Feed = @"me/feed";
NSString *const MUSFacebookGraphPath_Me_Photos = @"me/photos";
NSString *const MUSFacebookGraphPath_Search = @"/search?";

NSString *const MUSFacebookParametrsRequest = @"name,id,picture.type(large),gender,birthday,email,first_name,last_name,location,friends";
NSString *const MUSFacebookParameter_Fields = @"fields";
NSString *const MUSFacebookParameter_Message = @"message";
NSString *const MUSFacebookParameter_Place = @"place";
NSString *const MUSFacebookParameter_Picture = @"picture";

NSString *const MUSFacebookLocationParameter_Q = @"q";
NSString *const MUSFacebookLocationParameter_Type = @"type";
NSString *const MUSFacebookLocationParameter_Center = @"center";
NSString *const MUSFacebookLocationParameter_Distance = @"distance";

NSString *const MUSFacebookKeyOfPlaceDictionary = @"data";

NSString *const MUSFacebookError = @"Facebook error. Please retry again.";
NSInteger const MUSFacebookErrorCode = 1300;

NSString *const MUSFacebookSuccessUpdateNetworkPost = @"Facebook update all network posts";

NSString* const MUSFacebookParameter_ObjectId = @"ObjectId";
NSString* const MUSFacebookParameter_True = @"true";
NSString* const MUSFacebookParameter_Summary = @"summary";
NSString* const MUSFacebookParameter_Likes = @"likes";
NSString* const MUSFacebookParameter_Total_Count = @"total_count";
NSString* const MUSFacebookParameter_Comments = @"comments";
NSString *const MUSFacebookLocation_Parameter_Type_Place = @"place";
NSString *const MUSFacebookLocation_Parameter_Type_Distance = @"500";

#pragma mark Vkontakte Constants

NSString *const MUSVKAppID = @"5004830";
NSString *const MUSVKAllUserFields = @"first_name,last_name,photo_200_orig,id,birthday";
NSString *const MUSVKTitle = @"Login VK";
NSString *const MUSVKIconName = @"VK_icon.png";
NSString *const MUSVKName = @"VKontakt";

NSString *const MUSVKMethodPlacesSearch = @"places.search";
NSString *const MUSVKMethodWallGetById = @"wall.getById";

NSString *const MUSVKParameter_Photo = @"photo";
NSString *const MUSVKParameter_Posts = @"posts";

NSString *const MUSVKLocationParameter_Q = @"q";
NSString *const MUSVKLocationParameter_Latitude = @"latitude";
NSString *const MUSVKLocationParameter_Longitude = @"longitude";
NSString *const MUSVKLocationParameter_Radius = @"radius";

NSString *const MUSVKKeyOfPlaceDictionary = @"items";

NSInteger const MUSVKDistanceEqual300 = 300;
NSInteger const MUSVKDistanceEqual2400 = 2400;
NSInteger const MUSVKDistanceEqual18000 = 18000;

NSString *const MUSVKSuccessUpdateNetworkPost = @"VK update all network posts";

NSString *const MUSVKError = @"Vkontakte error. Please retry again.";
NSInteger const MUSVKErrorCode = 1100;


#pragma mark Twitter Contants
NSString *const MUSTwitterConsumerSecret = @"sQNqSfSGW5lksTvqTCqn407pSQXUNCBvIsHJrOYlNKMhREtyT2";
NSString *const MUSTwitterConsumerKey = @"lUY36ubrBYXpYsZhJJvg8CYdf";

NSString *const MUSTwitterTitle = @"Login Twitter";
NSString *const MUSTwitterIconName = @"Twitter_icon.png";
NSString *const MUSTwitterName = @"Twitter";

NSString *const MUSTwitterError = @"Twitter error. Please retry again.";
NSInteger const MUSTwitterErrorCode = 1200;

NSString* const MUSTwitterLocationParameter_Latitude = @"lat";
NSString* const MUSTwitterLocationParameter_Longituge = @"long";

NSString *const MUSTwitterURL_Statuses_Show = @"https://api.twitter.com/1.1/statuses/show.json";
NSString *const MUSTwitterURL_Api_Url = @"https://api.twitter.com";
NSString* const MUSTwitterURL_Geo_Search = @"https://api.twitter.com/1.1/geo/search.json";
NSString* const MUSTwitterURL_Statuses_Update = @"https://api.twitter.com/1.1/statuses/update.json";
NSString* const MUSTwitterURL_Media_Upload = @"https://upload.twitter.com/1.1/media/upload.json";


NSString* const MUSTwitterParameter_Status = @"status";
//NSString* const MUSTwitterParameter_PlaceID = @"place_id";
NSString* const MUSTwitterParameter_MediaID = @"media_ids";
NSString* const MUSTwitterParameter_Media = @"media";

NSString* const MUSTwitterParameter_ID = @"id";
NSString* const MUSTwitterParameter_True = @"true";
NSString* const MUSTwitterParameter_Include_My_Retweet = @"include_my_retweet";
NSString* const MUSTwitterParameter_Favorite_Count = @"favorite_count";
NSString* const MUSTwitterParameter_Retweet_Count = @"retweet_count";

NSString* const MUSTwitterJSONParameterForMediaID = @"media_id_string";
NSString *const MUSTwitterSuccessUpdateNetworkPost = @"Twitter update all network posts";


#pragma mark General Constants

NSString *const MUSGET = @"GET";
NSString *const MUSPOST = @"POST";
NSString *const MUSPostSuccess = @"Your post has been sent";

#pragma mark Error Constants

NSString *const MUSLocationDistanceError = @"Please, change distance of your current location! And try again!";
NSInteger const MUSLocationDistanceErrorCode = 1010;

NSString *const MUSLocationPropertiesError = @"One of the parameters specified was missing or invalid. Please check next Location properties: \n 1) string search; \n 2) distance;";
NSInteger const MUSLocationPropertiesErrorCode = 1011;

NSString *const MUSAccessError = @"Access denied!";
NSInteger const MUSAccessErrorCode = 1020;
