//
//  MUSConstantsForParseSocialNetworkObjects.h
//  UniversalSharing
//
//  Created by U 2 on 15.10.15.
//  Copyright © 2015 Mobindustry. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////// Facebook Network ////////////////////////////////

#pragma FacebookNetwork

#pragma mark - ParsePlace

FOUNDATION_EXPORT NSString *const MUSFacebookParsePlace_ID;
FOUNDATION_EXPORT NSString *const MUSFacebookParsePlace_Name;
FOUNDATION_EXPORT NSString *const MUSFacebookParsePlace_Category;
FOUNDATION_EXPORT NSString *const MUSFacebookParsePlace_Location;
FOUNDATION_EXPORT NSString *const MUSFacebookParsePlace_Country;
FOUNDATION_EXPORT NSString *const MUSFacebookParsePlace_City;
FOUNDATION_EXPORT NSString *const MUSFacebookParsePlace_Longitude;
FOUNDATION_EXPORT NSString *const MUSFacebookParsePlace_Latitude;

#pragma mark - ParseUser

FOUNDATION_EXPORT NSString *const MUSFacebookParseUser_ID;
FOUNDATION_EXPORT NSString *const MUSFacebookParseUser_Name;
FOUNDATION_EXPORT NSString *const MUSFacebookParseUser_First_Name;
FOUNDATION_EXPORT NSString *const MUSFacebookParseUser_Last_Name;
FOUNDATION_EXPORT NSString *const MUSFacebookParseUser_Picture;
FOUNDATION_EXPORT NSString *const MUSFacebookParseUser_Data;
FOUNDATION_EXPORT NSString *const MUSFacebookParseUser_Photo_Url;

#pragma mark - NetworkPost

FOUNDATION_EXPORT NSString *const MUSFacebookParseNetworkPost_ID;


///////////////////////////////// VK Network /////////////////////////////////

#pragma VKNetwork

#pragma mark - ParsePlace

FOUNDATION_EXPORT NSString *const MUSVKParsePlace_ID;
FOUNDATION_EXPORT NSString *const MUSVKParsePlace_Title;
FOUNDATION_EXPORT NSString *const MUSVKParsePlace_Type;
FOUNDATION_EXPORT NSString *const MUSVKParsePlace_Country;
FOUNDATION_EXPORT NSString *const MUSVKParsePlace_City;
FOUNDATION_EXPORT NSString *const MUSVKParsePlace_Longitude;
FOUNDATION_EXPORT NSString *const MUSVKParsePlace_Latitude;

#pragma mark - ParseUser

FOUNDATION_EXPORT NSString *const MUSVKParseUser_BirthDate;
FOUNDATION_EXPORT NSString *const MUSVKParseUser_City;
FOUNDATION_EXPORT NSString *const MUSVKParseUser_Title;
FOUNDATION_EXPORT NSString *const MUSVKParseUser_First_Name;
FOUNDATION_EXPORT NSString *const MUSVKParseUser_Last_Name;
FOUNDATION_EXPORT NSString *const MUSVKParseUser_ID;
FOUNDATION_EXPORT NSString *const MUSVKParseUser_Photo_Url;

#pragma mark - NetworkPost

FOUNDATION_EXPORT NSString *const MUSVKParsePost_ID;
FOUNDATION_EXPORT NSString *const MUSVKParseNetworkPost_ID;
FOUNDATION_EXPORT NSString *const MUSVKParseNetworkPost_Likes;
FOUNDATION_EXPORT NSString *const MUSVKParseNetworkPost_Comments;
FOUNDATION_EXPORT NSString *const MUSVKParseNetworkPost_Count;

////////////////////////////// Twitter Network ////////////////////////////////

#pragma Twitter

#pragma mark - ParsePlace

FOUNDATION_EXPORT NSString *const MUSTwitterParsePlace_ID;
FOUNDATION_EXPORT NSString *const MUSTwitterParsePlace_Place_Type;
FOUNDATION_EXPORT NSString *const MUSTwitterParsePlace_Country;
FOUNDATION_EXPORT NSString *const MUSTwitterParsePlace_Full_Name;
FOUNDATION_EXPORT NSString *const MUSTwitterParsePlace_Contained_Within;
FOUNDATION_EXPORT NSString *const MUSTwitterParsePlace_Name;
FOUNDATION_EXPORT NSString *const MUSTwitterParsePlace_Centroid;

#pragma mark - ParseLocation

FOUNDATION_EXPORT NSString *const MUSTwitterParseLocation_Result;
FOUNDATION_EXPORT NSString *const MUSTwitterParseLocation_Places;
