//
//  ServerCommunicationUtil.h
//  3G Data
//
//  Created by Dimitar Valentinov Petrov on 4/27/15.
//  Copyright (c) 2015 Dimitar Valentinov Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerCommunicationUtil : NSObject

//not needed - remove?
+(id) sharedInstance;

+(void)getMobileDataInfo;

+(void)parseServerResultFromString:(NSString*)strSource;


//data
+(BOOL)isThereSavedData;

+(NSInteger)usedInternet;
+(NSInteger)leftInternet;
+(NSInteger)totalInternet;

+(NSString*)percentage;
+(NSString*)dueDate;

@end
