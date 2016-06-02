//
//  HeartRateViewController.m
//  MyHealthApp
//
//  Created by saranya.ravi@philips.com on 01/06/16.
//  Copyright © 2016 saranya.ravi@philips.com. All rights reserved.
//

#import "HeartRateViewController.h"
#import "HKHealthStore+AAPLExtensions.h"

@interface HeartRateViewController ()
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;


@end

@implementation HeartRateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.healthStore = [[HKHealthStore alloc] init];
	
	if ([HKHealthStore isHealthDataAvailable]) {
		NSSet *readDataTypes = [self dataTypesToRead];
		
		[self.healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
			if (!success) {
				NSLog(@"You didn't allow HealthKit to access these read/write data types %@", error);
				return;
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
			});
		}];
	}
	
}

- (NSSet *)dataTypesToRead {
	HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
	return [NSSet setWithObjects:heartRateType, nil];
}

- (IBAction)updateHeartRate:(id)sender {
	HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
	
	[self.healthStore aapl_mostRecentQuantitySampleOfType:heartRateType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
		if (!mostRecentQuantity) {
			NSLog(@"Either an error occured fetching the user's heart rate information or none has been stored yet");
			dispatch_async(dispatch_get_main_queue(), ^{
				self.heartRateLabel.text = @"--";
			});
		}
		else {
			HKUnit *heartRateUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
			double heartRate = [mostRecentQuantity doubleValueForUnit:heartRateUnit];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				self.heartRateLabel.text = [NSNumberFormatter localizedStringFromNumber:@(heartRate) numberStyle:NSNumberFormatterNoStyle];
			});
		}
	}];
}


@end
