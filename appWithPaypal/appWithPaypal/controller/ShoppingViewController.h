//
//  ShoppingViewController.h
//  appWithPaypal
//
//  Created by Yiyuan Zhang on 7/16/15.
//  Copyright (c) 2015 Yiyuan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingViewController : UITableViewController
@property (nonatomic, retain) NSMutableArray *ProductData;
@property (retain) NSIndexPath* lastIndexPath;
@end
