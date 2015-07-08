//
//  ViewController.m
//  3G Data
//
//  Created by Dimitar Valentinov Petrov on 3/24/15.
//  Copyright (c) 2015 Dimitar Valentinov Petrov. All rights reserved.
//

#import "ViewController.h"

#define kNoDataYet @"no data yet"

@interface ViewController ()

//usedInternet + maxInternet
@property (weak, nonatomic) IBOutlet UILabel *lblInternetUsed;
@property (weak, nonatomic) IBOutlet UILabel *lblInternetLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblInternetTotal;

//dueDate
@property (weak, nonatomic) IBOutlet UILabel *lblDueDate;

//percentage
@property (weak, nonatomic) IBOutlet UILabel *lblPercentage;

//progress bar
@property (weak, nonatomic) IBOutlet UIProgressView *progressViewUsedInternet;

//activity indicator
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIndCheckingData;

//button
@property (weak, nonatomic) IBOutlet UIButton *btnCheckThreeG;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //register for notification center
    [self registerForNotificationCenter];

    //config
    [self displayMobileDataInformation];
//    [self configThreeGButton];
//    [self.btnCheckThreeG setBackgroundColor:[UIColor lightGrayColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkThreeGUsage:(id)sender {
    if (!self.actIndCheckingData.isAnimating) {
        [self startAnimating];
        [ServerCommunicationUtil getMobileDataInfo];
//        [ServerCommunicationUtil parseServerResultFromString:kServerResult];
    }
}

//not used - custom layout for 'Check my 3G' button
//-(void)configThreeGButton {
//    [[self.btnCheckThreeG layer] setBorderWidth:1.0f];
//    [[self.btnCheckThreeG layer] setBorderColor:[UIColor blueColor].CGColor];
//}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //remove observer self
    [self removeObserverFromNotificationCenter];
}

#pragma mark - data

-(void)displayMobileDataInformation {
    
    if ([ServerCommunicationUtil isThereSavedData]) {
        
        self.lblInternetLeft.text = [NSString stringWithFormat:@"%ld MB", (long)[ServerCommunicationUtil leftInternet]];
        self.lblInternetTotal.text = [NSString stringWithFormat:@"%ld MB", (long)[ServerCommunicationUtil totalInternet]];
        self.lblInternetUsed.text = [NSString stringWithFormat:@"%ld MB", (long)[ServerCommunicationUtil usedInternet]];
        
        self.lblDueDate.text = [ServerCommunicationUtil dueDate];
        self.lblPercentage.text = [ServerCommunicationUtil percentage];
        
        //progress bar
        self.progressViewUsedInternet.progress = [self.lblPercentage.text floatValue]/100;
    }
    else {
        
        self.lblInternetLeft.text = kNoDataYet;
        self.lblInternetTotal.text = kNoDataYet;
        self.lblInternetUsed.text = kNoDataYet;
        
        self.lblDueDate.text = kNoDataYet;
        self.lblPercentage.text = @"0.0%";
        
        self.progressViewUsedInternet.progress = 0.0f;
    }
    
}

-(void)didParseData {
    //acitivity indicator
    [self stopAnimating];
    
    //functionality
    [self displayMobileDataInformation];
    [self reloadInputViews];
}


-(void)showAlert {
    //activity indicator
    [self stopAnimating];
    
    //show alert
    [[[UIAlertView alloc] initWithTitle:@"Грешка"
                                message:@"Можете да използвате услугата само през мрежата на Мтел"
                               delegate:self
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

#pragma mark - Activity Indicator

-(void)startAnimating {
    [self.actIndCheckingData startAnimating];
}

-(void)stopAnimating {
    [self.actIndCheckingData stopAnimating];
}

#pragma mark - Notification Center

-(void)registerForNotificationCenter {
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self
                      selector:@selector(didParseData)
                          name:kNotificationNameDataParsed
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(showAlert)
                          name:kNotificationNameConnectionError
                        object:nil];
}

-(void)removeObserverFromNotificationCenter {
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    
    
    [defaultCenter removeObserver:self
                             name:kNotificationNameDataParsed
                           object:nil];
    
    [defaultCenter removeObserver:self
                             name:kNotificationNameConnectionError
                           object:nil];
}

@end
