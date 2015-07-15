//
//  ItmeListController.h
//  appWithPaypal
//
//  Created by Yiyuan Zhang on 7/15/15.
//  Copyright (c) 2015 Yiyuan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"

@interface ItmeListController : UITableViewController<PayPalPaymentDelegate, PayPalFuturePaymentDelegate, PayPalProfileSharingDelegate, UIPopoverControllerDelegate>
@property (nonatomic, retain) NSMutableArray *tableData;
@property (retain) NSIndexPath* lastIndexPath;
@property(nonatomic, strong, readwrite) NSString *environment;
@property(nonatomic, assign, readwrite) BOOL acceptCreditCards;
@end
