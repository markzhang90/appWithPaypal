//
//  ShoppingViewController.m
//  appWithPaypal
//
//  Created by Yiyuan Zhang on 7/16/15.
//  Copyright (c) 2015 Yiyuan Zhang. All rights reserved.
//

#import "ShoppingViewController.h"
#import "Item.h"
#import "ShoppingCart.h"

@interface ShoppingViewController ()

@end

@implementation ShoppingViewController


@synthesize ProductData;

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    ProductData = [NSMutableArray arrayWithObjects: nil];
    Item *item1 = [[Item alloc] init];
    item1.price = @"10";
    item1.name = @"item1";
    [ProductData addObject:item1];
    Item *item2 = [[Item alloc] init];
    item2.price = @"20";
    item2.name = @"item2";
    
    [ProductData addObject:item2];
    for(Item *element in ProductData) {
        NSLog(@"%d", 1);
        NSLog(@"%@", element.name);
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [ProductData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"productItem" forIndexPath:indexPath];
    Item *currentItem = [ProductData objectAtIndex:indexPath.row];
    
    
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
- (IBAction)AddToCart:(UIBarButtonItem *)sender {
    
    if (self.lastIndexPath) {
        

    Item *pay_item = [ProductData objectAtIndex:self.lastIndexPath.row];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ShoppingCart" inManagedObjectContext:context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", pay_item.name];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
        
//if exist record update
    if ([result count] > 0) {
        NSManagedObject *matches = result[0];
        int count = [[matches valueForKey:@"count"] intValue] + 1;
        [matches setValue: [NSNumber numberWithInteger:count]forKey:@"count"];
        if (![matches.managedObjectContext save:&error]) {
            NSLog(@"Unable to save managed object context.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success"
                                                        message:@"updated count"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
//    have new record
        NSManagedObject *add_new = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"ShoppingCart"
                                    inManagedObjectContext:context];
        [add_new setValue:pay_item.name forKey:@"name"];
        [add_new setValue:[NSNumber numberWithInteger: [pay_item.price intValue]] forKey:@"price"];
        [add_new setValue:[NSNumber numberWithInteger:1] forKey:@"count"];
        
        if (![add_new.managedObjectContext save:&error]) {
            NSLog(@"Unable to save managed object context.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success"
                                                        message:@"new item added"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    }
    
    
    
    
    
    
}

@end
