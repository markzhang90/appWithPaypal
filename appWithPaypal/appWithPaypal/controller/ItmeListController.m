//
//  ItmeListController.m
//  appWithPaypal
//
//  Created by Yiyuan Zhang on 7/15/15.
//  Copyright (c) 2015 Yiyuan Zhang. All rights reserved.
//

#import "ItmeListController.h"
#import "Item.h"
#import <QuartzCore/QuartzCore.h>

#define kPayPalEnvironment PayPalEnvironmentNoNetwork

@interface ItmeListController ()
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@end

@implementation ItmeListController
@synthesize tableData;

- (void)viewDidLoad {
    [super viewDidLoad];
    tableData = [NSMutableArray arrayWithObjects: nil];
    Item *item1 = [[Item alloc] init];
    item1.price = @"10";
    item1.name = @"item1";
    [tableData addObject:item1];
    
    Item *item2 = [[Item alloc] init];
    item2.price = @"20";
    item2.name = @"item2";
    
    [tableData addObject:item2];
    for(Item *element in tableData) {
        NSLog(@"%d", 1);
        NSLog(@"%@", element.name);
    }
//    NSLog(@"%lu", (unsigned long)[tableData count]);
//    NSLog(@"%@", item1.name);
//    
    
    // Set up payPalConfig
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards= YES;
    _payPalConfig.merchantName = @"Test Shop.";
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    
    // Setting the languageOrLocale property is optional.
    //
    // Do any additional setup after loading the view.
    
    _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    
    
    // Setting the payPalShippingAddressOption property is optional.
    //
    // See PayPalConfiguration.h for details.
    
    _payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    
    // Do any additional setup after loading the view, typically from a nib.
    
    // use default environment, should be Production in real life
    self.environment = kPayPalEnvironment;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    // Preconnect to PayPal early
    [self setPayPalEnvironment:self.environment];
}

- (void)setPayPalEnvironment:(NSString *)environment {
    self.environment = environment;
    [PayPalMobile preconnectWithEnvironment:environment];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableItem" forIndexPath:indexPath];
    Item *currentItem = [tableData objectAtIndex:indexPath.row];
    
    
    cell.textLabel.text = currentItem.name;
    cell.detailTextLabel.text = currentItem.price;
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.lastIndexPath==indexPath) return; // nothing to do
    
    // deselect old
    UITableViewCell *old = [self.tableView cellForRowAtIndexPath:self.lastIndexPath];
    old.accessoryType = UITableViewCellAccessoryNone;
    [old setSelected:FALSE animated:TRUE];
    
    // select new
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [cell setSelected:TRUE animated:TRUE];
    
    // keep track of the last selected cell
    self.lastIndexPath = indexPath;
}

- (IBAction)pay:(UIBarButtonItem *)sender {
    
    // Note: For purposes of illustration, this example shows a payment that includes
    //       both payment details (subtotal, shipping, tax) and multiple items.
    //       You would only specify these if appropriate to your situation.
    //       Otherwise, you can leave payment.items and/or payment.paymentDetails nil,
    //       and simply set payment.amount to your total charge.
    
    // Optional: include multiple items
    PayPalItem *item1 = [self setPayItem];
    if(item1 != nil){
        NSArray *items = @[item1];
        NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];
    
    // Optional: include payment details
        NSDecimalNumber *shipping = [[NSDecimalNumber alloc] initWithString:@"0"];
        NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithString:@"0"];
        PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal
                                                                               withShipping:shipping
                                                                                    withTax:tax];
        
        NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];
    
        PayPalPayment *payment = [[PayPalPayment alloc] init];
        payment.amount = total;
        payment.currencyCode = @"USD";
        payment.shortDescription = @"Hipster clothing";
        payment.items = items;  // if not including multiple items, then leave payment.items as nil
        payment.paymentDetails = paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil
    
        if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
        }
    
    // Update payPalConfig re accepting credit cards.
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards;
    
        PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfig
                                                                                                     delegate:self];
        [self presentViewController:paymentViewController animated:YES completion:nil];
    }
}

- (PayPalItem *) setPayItem{
    if (self.lastIndexPath) {
        
        Item *pay_item = [tableData objectAtIndex:self.lastIndexPath.row];
        PayPalItem *this_item = [PayPalItem itemWithName:pay_item.name
                                            withQuantity:1
                                               withPrice:[NSDecimalNumber decimalNumberWithString:pay_item.price]
                                            withCurrency:@"USD"
                                                 withSku:@"0"];
        return this_item;
        
    }
    return nil;
    
    
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}


#pragma mark - Authorize Future Payments

- (IBAction)getUserAuthorizationForFuturePayments:(id)sender {
    
    PayPalFuturePaymentViewController *futurePaymentViewController = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:self.payPalConfig delegate:self];
    [self presentViewController:futurePaymentViewController animated:YES completion:nil];
}


#pragma mark PayPalFuturePaymentDelegate methods

- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController
                didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {
    NSLog(@"PayPal Future Payment Authorization Success!");
   
    [self sendFuturePaymentAuthorizationToServer:futurePaymentAuthorization];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {
    NSLog(@"PayPal Future Payment Authorization Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendFuturePaymentAuthorizationToServer:(NSDictionary *)authorization {
    // TODO: Send authorization to server
    NSLog(@"Here is your authorization:\n\n%@\n\nSend this to your server to complete future payment setup.", authorization);
}


#pragma mark - Authorize Profile Sharing

- (IBAction)getUserAuthorizationForProfileSharing:(id)sender {
    
    NSSet *scopeValues = [NSSet setWithArray:@[kPayPalOAuth2ScopeOpenId, kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeAddress, kPayPalOAuth2ScopePhone]];
    
    PayPalProfileSharingViewController *profileSharingPaymentViewController = [[PayPalProfileSharingViewController alloc] initWithScopeValues:scopeValues configuration:self.payPalConfig delegate:self];
    [self presentViewController:profileSharingPaymentViewController animated:YES completion:nil];
}


#pragma mark PayPalProfileSharingDelegate methods

- (void)payPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController
             userDidLogInWithAuthorization:(NSDictionary *)profileSharingAuthorization {
    NSLog(@"PayPal Profile Sharing Authorization Success!");
    
    [self sendProfileSharingAuthorizationToServer:profileSharingAuthorization];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidCancelPayPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController {
    NSLog(@"PayPal Profile Sharing Authorization Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendProfileSharingAuthorizationToServer:(NSDictionary *)authorization {
    // TODO: Send authorization to server
    NSLog(@"Here is your authorization:\n\n%@\n\nSend this to your server to complete profile sharing setup.", authorization);
}


#pragma mark - Flipside View Controller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"pushSettings"]) {
        [[segue destinationViewController] setDelegate:(id)self];
    }
}



@end
