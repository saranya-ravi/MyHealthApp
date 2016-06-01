//
//  FoodIntakeViewController.m
//  MyHealthApp
//
//  Created by saranya.ravi@philips.com on 31/05/16.
//  Copyright © 2016 saranya.ravi@philips.com. All rights reserved.
//

#import "FoodIntakeViewController.h"

@interface FoodIntakeViewController ()

@end

@implementation FoodIntakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
	} else {
	cell.accessoryType =UITableViewCellAccessoryCheckmark;
	}
}

@end
