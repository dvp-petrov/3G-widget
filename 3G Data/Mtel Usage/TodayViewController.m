//
//  TodayViewController.m
//  Mtel Usage
//
//  Created by Dimitar Valentinov Petrov on 6/16/15.
//  Copyright (c) 2015 Dimitar Valentinov Petrov. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>


#define kWClosedHeight      37.0f
#define kWExpandedHeight    156.0f
#define kNoDataYet          @"no data yet"

/*
 Discussion:
 
    To Do:
 Transform static property to NSUserDefaults NSNumber numberWithInteger.
 
    To Check:
 To Check if NSUserDefaults are shared between Today's Extension and the Main App?
 */

@interface TodayViewController () <NCWidgetProviding>

//ui starter
@property (weak, nonatomic) IBOutlet UIProgressView *progressViewInternetUsed;
@property (weak, nonatomic) IBOutlet UILabel *lblPercentageInternetUsed;

//detail info
@property (weak, nonatomic) IBOutlet UILabel *lblUsed;
@property (weak, nonatomic) IBOutlet UILabel *lblLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblTotal;
@property (weak, nonatomic) IBOutlet UILabel *lblDueDate;
//data
@property (weak, nonatomic) IBOutlet UILabel *lblDataUsed;
@property (weak, nonatomic) IBOutlet UILabel *lblDataLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblDataTotal;
@property (weak, nonatomic) IBOutlet UILabel *lblDataDueDate;

//properties
@property (nonatomic) BOOL isDetailShown;
@property (nonatomic) BOOL shouldUpdateWidgit;

//last request time
@property(nonatomic) NSTimeInterval timeIntervalLastRequest;

@end


@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self registerForNotifications];
    [self updateUserInterface];
    
    [self setPreferredContentSize:CGSizeMake(0.0, kWClosedHeight)];
    [self hideDetailUserInterface];
    
    
    [self checkLastRequestTime];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}
 */

#pragma mark - NCWidgetProviding Protocol

-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    defaultMarginInsets.bottom = 10.0f;
    
    return defaultMarginInsets;
}

-(void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    
    [self updateUserInterface];
    
    //catch notificaiton -> property shouldUpdateWidget
    if (self.shouldUpdateWidgit) {
        completionHandler(NCUpdateResultNewData);
        self.shouldUpdateWidgit = NO;
    } else {
        completionHandler(NCUpdateResultNoData);
    }
}

#pragma mark - Data Updates

//check timeIntervalFromLastConnection
-(void)shouldMakeRequest {
    
    if ([self shouldMakeRequestWithLastTimeInterval]) {
        [self makeRequest];
    }
    
}

//Connect Server
-(void)makeRequest {
//    [ServerCommunicationUtil parseServerResultFromString:kServerResult];
    [ServerCommunicationUtil getMobileDataInfo];
    [self changeLastRequestTimeToNow];
}

//remove observer? to-do:
-(void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shouldUpdateWidgitNow)
                                                 name:kNotificationNameDataParsed
                                               object:nil];
}

-(void)shouldUpdateWidgitNow {
    self.shouldUpdateWidgit = YES;
}

#pragma mark - UI Updates

-(void)updateUserInterface {
    
    if ([ServerCommunicationUtil isThereSavedData]) {
        //starter data
        self.progressViewInternetUsed.progress = [[ServerCommunicationUtil percentage] floatValue]/100;
        self.lblPercentageInternetUsed.text = [ServerCommunicationUtil percentage];
        
        //detail data
        self.lblDataLeft.text = [NSString stringWithFormat:@"%ld MB", (long)[ServerCommunicationUtil leftInternet]];
        self.lblDataTotal.text = [NSString stringWithFormat:@"%ld MB", (long)[ServerCommunicationUtil totalInternet]];
        self.lblDataUsed.text = [NSString stringWithFormat:@"%ld MB", (long)[ServerCommunicationUtil usedInternet]];
        self.lblDataDueDate.text = [ServerCommunicationUtil dueDate];
    }
    else {
        //starter data
        self.progressViewInternetUsed.progress = 0.0f;
        self.lblPercentageInternetUsed.text = @"0.0%";
        
        //detail data
        self.lblDataLeft.text       =   kNoDataYet;
        self.lblDataTotal.text      =   kNoDataYet;
        self.lblDataUsed.text       =   kNoDataYet;
        self.lblDataDueDate.text    =   kNoDataYet;
    }
}

//hide detail UI
-(void)hideDetailUserInterface {
    [self changeDetailUserInterfaceAlphaTo:0];
    self.isDetailShown = NO;
}

-(void)showDetailUserInterface {
    [self changeDetailUserInterfaceAlphaTo:1];
    self.isDetailShown = YES;
}

-(void)changeDetailUserInterfaceAlphaTo:(CGFloat)alpha {
    [self.lblUsed setAlpha:alpha];
    [self.lblLeft setAlpha:alpha];
    [self.lblTotal setAlpha:alpha];
    [self.lblDueDate setAlpha:alpha];
    
    [self.lblDataUsed setAlpha:alpha];
    [self.lblDataLeft setAlpha:alpha];
    [self.lblDataTotal setAlpha:alpha];
    [self.lblDataDueDate setAlpha:alpha];
}

#pragma mark - Widget Methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isDetailShown) {
        [self setPreferredContentSize:CGSizeMake(0, kWClosedHeight)];
    }
    else {
        //update data
        [self updateUserInterface];
        //expand widget
        [self setPreferredContentSize:CGSizeMake(0, kWExpandedHeight)];
    }
}

-(void)viewWillTransitionToSize:(CGSize)size
      withTransitionCoordinator:
(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:
     ^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         if (self.isDetailShown) {
             [self hideDetailUserInterface];
         }
         else {
             [self showDetailUserInterface];
         }
     } completion:nil];
}


#pragma mark - User Defaults LastRequestTime
/*
 Last Request Time
 */

-(void)checkLastRequestTime {
    
    [self getLastRequestTimeFromUserDefaults];
    
    if (self.timeIntervalLastRequest == 0) {
        //make request
        [self makeRequest];
    }
    else {
        //check for need to makeRequest
        [self shouldMakeRequest];
    }
}

-(void)saveLastRequestTimeInUserDefaults {
    [[NSUserDefaults standardUserDefaults] setDouble:self.timeIntervalLastRequest
                                              forKey:kUserDefaultKeyLastRequest];
}

-(void)getLastRequestTimeFromUserDefaults {
    //check if this works...
    if ([[NSUserDefaults standardUserDefaults] doubleForKey:kUserDefaultKeyLastRequest] > 0) {
        self.timeIntervalLastRequest = [[NSUserDefaults standardUserDefaults] doubleForKey:kUserDefaultKeyLastRequest];
    }
    else {
        self.timeIntervalLastRequest = 0;
    }

}

-(void)changeLastRequestTimeToNow {
    self.timeIntervalLastRequest = [[NSDate date] timeIntervalSince1970];
}

-(BOOL)shouldMakeRequestWithLastTimeInterval {
    
    NSTimeInterval timeIntervalNow = [[NSDate date] timeIntervalSince1970];
    
    if ((timeIntervalNow - self.timeIntervalLastRequest) > 5 * 60) {
        return YES;
    }
    
    return NO;
}

@end
