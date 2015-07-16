//
//  ShoppingCart.h
//  
//
//  Created by Yiyuan Zhang on 7/16/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ShoppingCart : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;

@end
