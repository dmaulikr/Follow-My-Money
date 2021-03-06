//
//  SettingsViewController.m
//  BudgetTest
//
//  Created by Joe Cortopassi on 9/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "ItemDateViewController.h"
#import "LegalViewController.h"
#import "CHCSV.h"
#import "FMMButton.h"

@implementation SettingsViewController

@synthesize managedObjectContext;
@synthesize scrollView;
@synthesize userDefaults;
@synthesize period_start_date, backup_email, backup_to_date, backup_from_date;
@synthesize period_interval;
@synthesize period_interval_label;
@synthesize periodStartDatePicker, backupFromDatePicker, backupToDatePicker;






-(IBAction)openQuickConversions
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://joecortopassi.com/apps/app_store.php?from=follow_my_money&to=quick_conversions"]];
}


-(IBAction)openSimpleKnot
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://joecortopassi.com/apps/app_store.php?from=follow_my_money&to=simple_knot"]];
}


-(IBAction)openWebsite
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://joecortopassi.com?appsource=followmymoney"]];
}


-(IBAction)openPrivacy
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://policy-portal.truste.com/core/privacy-policy/Joe-Cortopassi/7f906e01-9438-43e5-b124-9af8e2cbb2c6#landingPage"]];
}


-(IBAction)sendEmail
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setToRecipients:[NSArray arrayWithObject:@"followmymoney@joecortopassi.com"]];
        [mailComposer setSubject:@"Feedback: 'Follow my Money'"];
        [mailComposer setMessageBody:[NSString stringWithFormat:@"1. My favorite feature is...\n\n\n2. The one thing I wish would be better is...\n\n\n3. If I could have you add one feature, it would be...\n\n" ] isHTML:NO];
        
        [self presentModalViewController:mailComposer animated:YES];
    }
}




-(void)setPickersDate:(NSDate *)newDate forField:(NSString *)newFieldToSet
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat: @"M/d/Y"];
    if ([newFieldToSet isEqualToString:@"periodStartDate"]) {
        self.period_start_date.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:newDate]];
    } else if ([newFieldToSet isEqualToString:@"backupFromDate"]) {
        self.backup_from_date.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:newDate]];
    } else if ([newFieldToSet isEqualToString:@"backupToDate"]) {
        self.backup_to_date.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:newDate]];
    } else {
        // Where did this come from
    }
}

-(IBAction)pickPeriodStartDate
{
    self.periodStartDatePicker = [[ItemDateViewController alloc] init];
    self.periodStartDatePicker.fieldToSet = @"periodStartDate";
    self.periodStartDatePicker.delegate = self;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    self.periodStartDatePicker.date = [dateFormat dateFromString:self.period_start_date.text];
    [self presentModalViewController:self.periodStartDatePicker animated:YES];
}

-(IBAction)setPeriodDefaults
{
    [self.userDefaults setObject:self.period_start_date.text forKey:@"period_start_date"];
    [self.userDefaults setFloat:self.period_interval.value forKey:@"period_interval"];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Saved!"
                          message: @"Your default budget period has been saved."
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

-(IBAction)pickBackupFromDate
{
    self.backupFromDatePicker = [[ItemDateViewController alloc] init];
    self.backupFromDatePicker.fieldToSet = @"backupFromDate";
    self.backupFromDatePicker.delegate = self;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
    self.backupFromDatePicker.date = [dateFormat dateFromString:self.backup_from_date.text];
    [self presentModalViewController:self.backupFromDatePicker animated:YES];
}

-(IBAction)pickBackupToDate
{
    self.backupToDatePicker = [[ItemDateViewController alloc] init];
    self.backupToDatePicker.fieldToSet = @"backupToDate";
    self.backupToDatePicker.delegate = self;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
    self.backupToDatePicker.date = [dateFormat dateFromString:self.backup_to_date.text];
    [self presentModalViewController:self.backupToDatePicker animated:YES];
}


-(IBAction)sendBackupEmail
{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
    
    // Get all the 'BudgetItems'
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BudgetItems"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date > %@ AND date < %@ ", [dateFormat dateFromString:self.backup_from_date.text], [dateFormat dateFromString:self.backup_to_date.text]];
    NSLog(@"..%@..%@",self.backup_from_date.text,self.backup_to_date.text);
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    
    // Store the fetched 'BudgetItems'
    NSMutableArray *itemList = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    NSLog(@".%@",itemList);
    NSMutableArray *item_list_array = [[NSMutableArray alloc] init];
    //Set titles
    [item_list_array addObject:[[NSArray alloc] initWithObjects:@"Date", @"Name of Item", @"Amount", @"Category", nil]];
    
    for ( int i = 0; i < [itemList count]; i++) {
        NSString *date = [dateFormat stringFromDate:[[itemList objectAtIndex:i] valueForKey:@"date"]];
        NSString *item = [[itemList objectAtIndex:i] valueForKey:@"item"];
        NSString *amount = [[[itemList objectAtIndex:i] valueForKey:@"amount"] stringValue];
        NSString *category = [[[itemList objectAtIndex:i] valueForKey:@"category"] valueForKey:@"name"];
        
        [item_list_array addObject:[[NSArray alloc] initWithObjects:date, item, amount, category, nil]];
    }
    
    NSLog(@".%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]);
    
    NSString *CSVFile = [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"email_backup.csv"];
    
    [item_list_array writeToCSVFile:CSVFile atomically:YES error:&error];
    NSLog(@"...%@",item_list_array);
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:@"Back-up of budget items"];
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:CSVFile] mimeType:@"text/csv" fileName:@"budget_backup.csv"];
        [mailComposer setMessageBody:[NSString stringWithFormat:@"Here is the backup for %@ to %@ of all your budget items.", self.backup_from_date.text,self.backup_to_date.text ] isHTML:NO];
        
        [self presentModalViewController:mailComposer animated:YES];
    }
}

-(IBAction)periodIntervalSlider
{
    float slider = self.period_interval.value;

    if ( slider < 0.25 ) {
        self.period_interval_label.text = @"Weekly";
        self.period_interval.value = 0;
    } else if ( slider >= 0.25 && slider < 0.5 ) {
        self.period_interval_label.text = @"Every two weeks";
        self.period_interval.value = 0.375;
    } else if ( slider >= 0.5 && slider < 0.75 ) {
        self.period_interval_label.text = @"Bi-monthly";
        self.period_interval.value = 0.675;
    } else {
        self.period_interval_label.text = @"Monthly";
        self.period_interval.value = 1;
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    //[[NSDate alloc] initWithTimeIntervalSince1970:1306886401]; 06/01/2011
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - MFMailComposeViewDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:242.0/255.0 blue:233.0/255.0 alpha:1.0];
    self.scrollView.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:242.0/255.0 blue:233.0/255.0 alpha:1.0];
    
    
    self.navigationController.navigationBarHidden = YES;
    self.scrollView.frame = [[UIScreen mainScreen] bounds];
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(320,1200)];

    self.userDefaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view from its nib.
    
    [self setupButtonDefaultSave];
    [self setupButtonBackupSend];
    [self setupButtonEmail];
    [self setupButtonLicensesAndLegal];
    [self setupButtonPrivacy];
    
    
    self.period_interval.minimumTrackTintColor = [UIColor colorWithRed:1.00/255.00 green:131.00/255.00 blue:37.00/255.00 alpha:1.0];
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat: @"M/d/Y"];
    
    if ( [self.userDefaults objectForKey:@"period_start_date"] != nil) {
        self.period_start_date.text = [NSString stringWithFormat:@"%@", [self.userDefaults objectForKey:@"period_start_date"]];
    } else {
        self.period_start_date.text = @"1/1/2013";
    }
    
    
    if ( [self.userDefaults objectForKey:@"period_interval"] != nil) {
        float slider = [self.userDefaults floatForKey:@"period_interval"];
        
        if ( slider < 0.25 ) {
            self.period_interval_label.text = @"Weekly";
            self.period_interval.value = 0;
        } else if ( slider >= 0.25 && slider < 0.5 ) {
            self.period_interval_label.text = @"Every two weeks";
            self.period_interval.value = 0.375;
        } else if ( slider >= 0.5 && slider < 0.75 ) {
            self.period_interval_label.text = @"Bi-monthly";
            self.period_interval.value = 0.675;
        } else {
            self.period_interval_label.text = @"Monthly";
            self.period_interval.value = 1;
        }
    } else {
        self.period_interval.value = 1;
    }
    
    self.backup_from_date.text = @"6/1/2011";
    self.backup_to_date.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[NSDate date]]];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[[GAIDictionaryBuilder createAppView]
                    set:NSStringFromClass([self class])
                    forKey:kGAIScreenName] build]];
}


- (void) setupButtonDefaultSave
{
    FMMButton *buttonSave = [[FMMButton alloc] initWithFrame:CGRectMake(228.0, 578.0, 72.0, 37.0)];
    buttonSave.titleLabel.text = @"Save";
    [buttonSave addTarget:self action:@selector(setPeriodDefaults) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:buttonSave];
}


- (void) setupButtonBackupSend
{
    FMMButton *buttonSend = [[FMMButton alloc] initWithFrame:CGRectMake(228.0, 904.0, 72.0, 37.0)];
    buttonSend.titleLabel.text = @"Send";
    [buttonSend addTarget:self action:@selector(sendBackupEmail) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:buttonSend];
}


- (void) setupButtonEmail
{
    FMMButton *buttonEmail = [[FMMButton alloc] initWithFrame:CGRectMake(50.0, 265.0, 220.0, 40.0)];
    buttonEmail.titleLabel.text = @"Email";
    [buttonEmail addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:buttonEmail];
}


- (void) setupButtonLicensesAndLegal
{
    FMMButton *buttonEmail = [[FMMButton alloc] initWithFrame:CGRectMake(0.0, (self.scrollView.contentSize.height - 120.0), self.scrollView.frame.size.width, 40.0)];
    buttonEmail.titleLabel.text = @"Legal/Licenses";
    [buttonEmail addTarget:self action:@selector(showViewLegal) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:buttonEmail];
}


- (void) setupButtonPrivacy
{
    FMMButton *buttonPrivacy = [[FMMButton alloc] initWithFrame:CGRectMake(0.0, (self.scrollView.contentSize.height - 70.0), self.scrollView.frame.size.width, 40.0)];
    buttonPrivacy.titleLabel.text = @"Privacy Policy";
    [buttonPrivacy addTarget:self action:@selector(openPrivacy) forControlEvents:UIControlEventTouchUpInside];

    [self.scrollView addSubview:buttonPrivacy];
}


-(void) showViewLegal
{
    LegalViewController *legalVC = [[LegalViewController alloc] init];
    [self.navigationController pushViewController:legalVC animated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
