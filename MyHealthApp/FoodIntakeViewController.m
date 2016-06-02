//
//  FoodIntakeViewController.m
//  MyHealthApp
//
//  Created by saranya.ravi@philips.com on 31/05/16.
//  Copyright © 2016 saranya.ravi@philips.com. All rights reserved.
//

#import "FoodIntakeViewController.h"
#import "FoodItem.h"

@interface FoodIntakeViewController ()
@property (nonatomic, strong) FoodItem *selectedFoodItem;
@property (nonatomic, strong) NSArray *foodItems;

@end

@implementation FoodIntakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.selectedFoodItems = [NSMutableArray new];
	
	self.foodItems = @[
        [FoodItem foodItemWithName:@"Coffee" calories:2.0],
		[FoodItem foodItemWithName:@"Tea" calories:1.0],
		[FoodItem foodItemWithName:@"Ham & cheese sandwich" calories:234.0],
		[FoodItem foodItemWithName:@"Ice cream" calories:207.0],
		[FoodItem foodItemWithName:@"Smoothie" calories:37.0],
		[FoodItem foodItemWithName:@"Cake" calories:239.0],
		];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:self.tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType =UITableViewCellAccessoryNone;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell.accessoryType ==UITableViewCellAccessoryCheckmark) {
		cell.accessoryType =UITableViewCellAccessoryNone;
		if ([self.selectedFoodItems containsObject:self.foodItems[indexPath.row]]) {
			[self.selectedFoodItems removeObject:self.foodItems[indexPath.row]];
		}
	} else {
		if (![self.selectedFoodItems containsObject:self.foodItems[indexPath.row]]) {
			[self.selectedFoodItems addObject:self.foodItems[indexPath.row]];
		}
		cell.accessoryType =UITableViewCellAccessoryCheckmark;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

@end
