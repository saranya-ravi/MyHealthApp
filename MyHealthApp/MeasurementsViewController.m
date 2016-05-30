//
//  MeasurementsViewController.m
//  MyHealthApp
//
//  Created by saranya.ravi@philips.com on 29/05/16.
//  Copyright © 2016 saranya.ravi@philips.com. All rights reserved.
//

#import "MeasurementsViewController.h"
#import "HKHealthStore+AAPLExtensions.h"

@interface MeasurementsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UITextField *heightTextField;

@end

@implementation MeasurementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.healthStore = [[HKHealthStore alloc] init];
	
	if ([HKHealthStore isHealthDataAvailable]) {
		NSSet *writeDataTypes = [self dataTypesToWrite];
		NSSet *readDataTypes = [self dataTypesToRead];
		
		[self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
			if (!success) {
				NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
				
				return;
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				// Update the user interface based on the current user's health information.
				[self updateUsersHeightLabel];
				[self updateUsersWeightLabel];
			});
		}];
	}

}

- (NSSet *)dataTypesToWrite {
	HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
	HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
	
	return [NSSet setWithObjects:heightType, weightType, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
	HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
	HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
	
	return [NSSet setWithObjects:heightType, weightType, nil];
}

- (void)updateUsersHeightLabel {
	// Fetch user's default height unit in inches.
	NSLengthFormatter *lengthFormatter = [[NSLengthFormatter alloc] init];
	lengthFormatter.unitStyle = NSFormattingUnitStyleLong;
	
	NSLengthFormatterUnit heightFormatterUnit = NSLengthFormatterUnitCentimeter;
	NSString *heightUnitString = [lengthFormatter unitStringFromValue:10 unit:heightFormatterUnit];
	NSString *localizedHeightUnitDescriptionFormat = NSLocalizedString(@"Height (%@)", nil);
	
	self.heightTextField.text = [NSString stringWithFormat:localizedHeightUnitDescriptionFormat, heightUnitString];
	
	HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
	
	// Query to get the user's latest height, if it exists.
	[self.healthStore aapl_mostRecentQuantitySampleOfType:heightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
		if (!mostRecentQuantity) {
			NSLog(@"Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.");
			
			dispatch_async(dispatch_get_main_queue(), ^{
				self.heightTextField.text = NSLocalizedString(@"Not available", nil);
			});
		}
		else {
			// Determine the height in the required unit.
			HKUnit *heightUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixCenti];
			double usersHeight = [mostRecentQuantity doubleValueForUnit:heightUnit];
			
			// Update the user interface.
			dispatch_async(dispatch_get_main_queue(), ^{
				self.heightTextField.text = [NSNumberFormatter localizedStringFromNumber:@(usersHeight) numberStyle:NSNumberFormatterNoStyle];
			});
		}
	}];
}

- (void)updateUsersWeightLabel {
	// Fetch the user's default weight unit in pounds.
	NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
	massFormatter.unitStyle = NSFormattingUnitStyleLong;
	
	NSMassFormatterUnit weightFormatterUnit = NSMassFormatterUnitKilogram;
	NSString *weightUnitString = [massFormatter unitStringFromValue:10 unit:weightFormatterUnit];
	NSString *localizedWeightUnitDescriptionFormat = NSLocalizedString(@"Weight (%@)", nil);
	
	self.weightTextField.text = [NSString stringWithFormat:localizedWeightUnitDescriptionFormat, weightUnitString];
	
	// Query to get the user's latest weight, if it exists.
	HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
	
	[self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
		if (!mostRecentQuantity) {
			NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.");
			
			dispatch_async(dispatch_get_main_queue(), ^{
				self.weightTextField.text = NSLocalizedString(@"Not available", nil);
			});
		}
		else {
			// Determine the weight in the required unit.
			HKUnit *weightUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
			double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
			
			// Update the user interface.
			dispatch_async(dispatch_get_main_queue(), ^{
				self.weightTextField.text = [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle];
			});
		}
	}];
}

#pragma mark - Writing HealthKit Data

- (void)saveHeightIntoHealthStore:(double)height {
	// Save the user's height into HealthKit.
	
	HKUnit *heightUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixCenti];
	HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:heightUnit doubleValue:height];
	
	HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
	NSDate *now = [NSDate date];
	
	HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:now endDate:now];
	
	[self.healthStore saveObject:heightSample withCompletion:^(BOOL success, NSError *error) {
		if (!success) {
			NSLog(@"An error occured saving the height sample %@. In your app, try to handle this gracefully. The error was: %@.", heightSample, error);
		} else {
			NSLog(@"Success!");
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			[self updateUsersHeightLabel];
		});
	}];
}

- (void)saveWeightIntoHealthStore:(double)weight {
	// Save the user's weight into HealthKit.
	HKUnit *weightUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
	HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:weightUnit doubleValue:weight];
	
	HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
	NSDate *now = [NSDate date];
	
	HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:now endDate:now];
	
	[self.healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
		if (!success) {
			NSLog(@"An error occured saving the weight sample %@. In your app, try to handle this gracefully. The error was: %@.", weightSample, error);
		} else {
			NSLog(@"Success!");
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self updateUsersWeightLabel];
		});
	}];
}

- (IBAction)save:(id)sender {

	[self saveHeightIntoHealthStore:self.heightTextField.text.doubleValue];
	[self saveWeightIntoHealthStore:self.weightTextField.text.doubleValue];
}

@end
