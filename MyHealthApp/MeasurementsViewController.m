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
				NSLog(@"You didn't allow HealthKit to access these read/write data types %@", error);
				
				return;
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
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

- (NSSet *)dataTypesToRead {
	HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
	HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
	
	return [NSSet setWithObjects:heightType, weightType, nil];
}

- (void)updateUsersHeightLabel {
	NSLengthFormatter *lengthFormatter = [[NSLengthFormatter alloc] init];
	lengthFormatter.unitStyle = NSFormattingUnitStyleLong;
	
	NSLengthFormatterUnit heightFormatterUnit = NSLengthFormatterUnitCentimeter;
	NSString *heightUnitString = [lengthFormatter unitStringFromValue:10 unit:heightFormatterUnit];
	NSString *localizedHeightUnitDescriptionFormat = NSLocalizedString(@"Height (%@)", nil);
	
	self.heightTextField.text = [NSString stringWithFormat:localizedHeightUnitDescriptionFormat, heightUnitString];
	
	HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
	
	[self.healthStore aapl_mostRecentQuantitySampleOfType:heightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
		if (!mostRecentQuantity) {
			NSLog(@"Either an error occured fetching the user's height information or none has been stored yet");
			
			dispatch_async(dispatch_get_main_queue(), ^{
				self.heightTextField.text = NSLocalizedString(@"Not available", nil);
			});
		}
		else {
			HKUnit *heightUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixCenti];
			double usersHeight = [mostRecentQuantity doubleValueForUnit:heightUnit];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				self.heightTextField.text = [NSNumberFormatter localizedStringFromNumber:@(usersHeight) numberStyle:NSNumberFormatterNoStyle];
			});
		}
	}];
}

- (void)updateUsersWeightLabel {
	NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
	massFormatter.unitStyle = NSFormattingUnitStyleLong;
	
	NSMassFormatterUnit weightFormatterUnit = NSMassFormatterUnitKilogram;
	NSString *weightUnitString = [massFormatter unitStringFromValue:10 unit:weightFormatterUnit];
	NSString *localizedWeightUnitDescriptionFormat = NSLocalizedString(@"Weight (%@)", nil);
	
	self.weightTextField.text = [NSString stringWithFormat:localizedWeightUnitDescriptionFormat, weightUnitString];
	
	HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
	
	[self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
		if (!mostRecentQuantity) {
			NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet");
			
			dispatch_async(dispatch_get_main_queue(), ^{
				self.weightTextField.text = NSLocalizedString(@"Not available", nil);
			});
		}
		else {
			HKUnit *weightUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
			double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				self.weightTextField.text = [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle];
			});
		}
	}];
}

#pragma mark - Writing HealthKit Data

- (void)saveHeightIntoHealthStore:(double)height {
	
	HKUnit *heightUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixCenti];
	HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:heightUnit doubleValue:height];
	
	HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
	NSDate *now = [NSDate date];
	
	HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:now endDate:now];
	
	[self.healthStore saveObject:heightSample withCompletion:^(BOOL success, NSError *error) {
		if (!success) {
			NSLog(@"An error occured saving the height sample %@. The error was: %@.", heightSample, error);
		} else {
			NSLog(@"Success!");
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			[self updateUsersHeightLabel];
		});
	}];
}

- (void)saveWeightIntoHealthStore:(double)weight {
	HKUnit *weightUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
	HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:weightUnit doubleValue:weight];
	
	HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
	NSDate *now = [NSDate date];
	
	HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:now endDate:now];
	
	[self.healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
		if (!success) {
			NSLog(@"An error occured saving the weight sample %@. The error was: %@.", weightSample, error);
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
