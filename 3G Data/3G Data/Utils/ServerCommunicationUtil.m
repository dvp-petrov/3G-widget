//
//  ServerCommunicationUtil.m
//  3G Data
//
//  Created by Dimitar Valentinov Petrov on 4/27/15.
//  Copyright (c) 2015 Dimitar Valentinov Petrov. All rights reserved.
//

#import "ServerCommunicationUtil.h"

@interface ServerCommunicationUtil ()

@end


@implementation ServerCommunicationUtil

#pragma mark - Singleton

static BOOL isInited = NO;

+(id) sharedInstance {
    static ServerCommunicationUtil* instance = nil;
    if (!instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[super alloc] init];
        });
    }
    return instance;
}

- (id)init
{
    if (!isInited) {
        self = [super init];
        if (self) {
            //self.taskList = [[NSMutableArray alloc] init];
        }
        isInited = YES;
    }
    return self;
}

+(id) alloc {
    return [ServerCommunicationUtil sharedInstance];
}

-(id) copy {
    return [ServerCommunicationUtil sharedInstance];
}

-(id) mutableCopy {
    return [ServerCommunicationUtil sharedInstance];
}

#pragma mark - Server Methods

+(void)getMobileDataInfo {
    
    //create the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kRequestUrl]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:@"GET"];
    [request setValue: @"text/html" forHTTPHeaderField:@"Content-Type"];
//    [request setValue: @"Document" forHTTPHeaderField:@"Resource-Type"];


//    [request setHTTPBody: [NSData data]];
    
    //create request manager
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    op.responseSerializer = [AFHTTPResponseSerializer serializer];

    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString* responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"JSON responseObject: %@ ",responseStr);
        
        
        [ServerCommunicationUtil parseServerResultFromString:responseStr];
        //        NSDictionary* dictResponse = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@, %d", [error localizedDescription], [error code]);
        
//        -1009 -> no internet
//        -1003 -> cannot find the wi-fi
//        -1011 -> server error 500
        
        //post notification for error
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameConnectionError object:self];
        
    }];
    
    [op start];

}


+(void)parseServerResultFromString:(NSString*)strSource {
    
    //on success
    
    //string to achieve
//    Имате активиран мобилен интернет с включени 512 МВ на максимална скорост за периода до 15.06.2015. Използвани са 35 МВ (7%).
    
    //locate header
    NSRange rangeHeader1 = [strSource rangeOfString:@"h1"];
    strSource = [strSource substringFromIndex:rangeHeader1.location-1];
    
    //cut the first Paragraph
    NSRange rangeValueData = [strSource rangeOfString:@"</p>"];
    strSource = [strSource substringFromIndex:rangeValueData.location+rangeValueData.length];
    
    //cut the starting symbol of the paragraph I need
    rangeValueData = [strSource rangeOfString:@"<p>"];
    strSource = [strSource substringFromIndex:rangeValueData.location+rangeValueData.length];
    
    //cut the final symbol of the paragraph I need
    rangeValueData = [strSource rangeOfString:@"</p>"];
    //the string i need to take data - achieved string
    strSource = [strSource substringToIndex:rangeValueData.location];
    
//        NSLog(@"from h1: %@", strSource);
    
//    maxInternet;              - 512 МВ
//    currentlyUsedInternet     - 35 МВ
//    dueDate                   - 15.06.2015
//    percentageUsedInternet    - (7%)//not the correct percentage - should be 14.+%
    
    //special "МВ" string
    if ([strSource containsString:@"МВ"]) {
//        NSLog(@"mb");
        
        //1)
        //create substring 1 - get the int value of MBs
        NSRange rangeMaxInternet = [strSource rangeOfString:@"МВ"];
        NSString* strMaxInternet = [strSource substringToIndex:rangeMaxInternet.location];
        
        //value of maxInternet
        NSInteger intInternetMax = [[[strMaxInternet componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] integerValue];
        
        
        //2)
        //create substring 2 - get the currently used MBs
        NSRange rangeCurrentInternet = [strSource rangeOfString:@"МВ" options:NSBackwardsSearch];//may be MB or GB
        NSString* strCurrentInternet = [strSource substringFromIndex:rangeCurrentInternet.location - 10];
        rangeCurrentInternet = [strCurrentInternet rangeOfString:@"МВ"];
        strCurrentInternet = [strCurrentInternet substringToIndex:rangeCurrentInternet.location];
        
        //value of currentInternet
        NSInteger intInternetCurrent = [[[strCurrentInternet componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] integerValue];
        
        
        //3)Should be moved elsewhere
        //Percentage used intenet -> 1)get the value from string; or 2)evalute it myself
        //can be calculated before displaying?
        /*
        double dblPercentageInternetUsed = intInternetMax / (double)intInternetCurrent;
        NSLog(@"Percentage: %.1f", dblPercentageInternetUsed);
         */
        
        //4) -> New 3)
        //optional: get Due Date -> 15.06.2015 //mb use dateFormatter
        NSString* strDueDate = [strSource substringFromIndex:rangeMaxInternet.location+rangeMaxInternet.length];
        NSRange rangeDueDate = [strDueDate rangeOfString:@"МВ" options:NSBackwardsSearch];
        strDueDate = [strDueDate substringToIndex:rangeDueDate.location - 10];
        
        //get only the dueDate from the upper string
        NSString *strDueDateOnly = @""; // the real dueDate!
        
        NSScanner *scanner = [NSScanner scannerWithString:strDueDate];
        NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        
        // Throw away characters before the first number.
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        
        // Collect numbers.
        [scanner scanCharactersFromSet:numbers intoString:&strDueDateOnly];
        
        //delete last '.'
        if ([[strDueDateOnly substringFromIndex:[strDueDateOnly length]-1] isEqualToString:@"."]) {
            strDueDateOnly = [strDueDateOnly substringToIndex:[strDueDateOnly length]-1];
        }
        
        
        //4)
        //save to userDefaults
        [ServerCommunicationUtil saveToUserDefaultsMobileDataMaxInternet:intInternetMax
                                                         currentInternet:intInternetCurrent
                                                                 dueDate:strDueDateOnly];
    }
    else {
        //do the same as top but if GB -> *1024 the value for MBs
        //GBs to MBs convert
        NSLog(@"NO MB!");//there is GB? - needs refactoring
        //see what to do
        //create substring 1,2
        //
    }
    
    //tell the vc that data is parsed!
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameDataParsed object:self];
}

#pragma mark - Save Data

+(void)saveToUserDefaultsMobileDataMaxInternet:(NSInteger)intInternetMax
                               currentInternet:(NSInteger)intInternetCurrent
                                       dueDate:(NSString*)strDueDate {
    
    //create instance for userDefaults
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    //save mobile data info
    //1 - inetMax
    [userDefaults setInteger:intInternetMax forKey:kUserDefaultKeyInternetMax];
    //2 - inetCurrent
    [userDefaults setInteger:intInternetCurrent forKey:kUserDefaultKeyInternetCurrent];
    //3 - strDueDate
    [userDefaults setObject:strDueDate forKey:kUserDefaultKeyDueDate];
    
    //save changes immediately
    [userDefaults synchronize];
}

#pragma mark - GET Data

+(BOOL)isThereSavedData {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKeyInternetMax]) {
        return YES;
    }

    return NO;
}

+(NSInteger)usedInternet {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyInternetCurrent];
}

+(NSInteger)leftInternet {
    return ([ServerCommunicationUtil totalInternet] - [ServerCommunicationUtil usedInternet]);
}

+(NSInteger)totalInternet {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyInternetMax];
}

//strings
+(NSString*)percentage {
    double dblPercentageUsed = [ServerCommunicationUtil usedInternet] /(double) [ServerCommunicationUtil totalInternet];
    
    //to convert the value in percentage || formarly and double between 0 and 1.
    dblPercentageUsed *= 100;
    
    if (dblPercentageUsed >= 100) {
        return @"100%";
    }
    
    return [NSString stringWithFormat:@"%.1f%@", dblPercentageUsed, @"%"];
}

+(NSString*)dueDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKeyDueDate];
}

@end
