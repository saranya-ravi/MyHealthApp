//
//  EnergyViewController.m
//  MyHealthApp
//
//  Created by saranya.ravi@philips.com on 01/06/16.
//  Copyright © 2016 saranya.ravi@philips.com. All rights reserved.
//

#import "EnergyViewController.h"
#import "FoodIntakeViewController.h"
#import "FoodItem.h"

@interface EnergyViewController ()
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeBurnLabel;
@property (weak, nonatomic) IBOutlet UILabel *netLabel;

@property (nonatomic) double activeEnergyBurned;
@property (nonatomic) double energyConsumed;
@property (nonatomic) double netEnergy;

@property (nonatomic, strong) NSArray *selectedFoodItems;
@property (nonatomic) NSMutableArray *foodItems;

@end

@implementation EnergyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.selectedFoodItems = [NSArray new];
	self.foodItems = [NSMutableArray array];
	
	self.healthStore = [[HKHealthStore alloc] init];
	
	if ([HKHealthStore isHealthDataAvailable]) {
		NSSet *readDataTypes = [self dataTypesToRead];
		NSSet *writeDataTypes = [self dataTypesToWrite];

		[self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
			if (!success) {
				NSLog(@"You didn't allow HealthKit to access these read/write data types %@", error);
				return;
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
			});
		}];
	}

}

- (NSSet *)dataTypesToWrite {
	HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
	HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
	
	return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, nil];
}

- (NSSet *)dataTypesToRead {
	HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
	HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
	
	return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, nil];
}


- (IBAction)unwindToEnergy:(UIStoryboardSegue *)segue {
	FoodIntakeViewController *foodPickerViewController = [segue sourceViewController];
	self.selectedFoodItems = [self.selectedFoodItems arrayByAddingObjectsFromArray:foodPickerViewController.selectedFoodItems];
	
	[self addFoodItemsToHealthKit:self.selectedFoodItems];
	
	[self refreshStatistics];
}

- (HKCorrelation *)foodCorrelationForFoodItem:(FoodItem *)foodItem {
	NSDate *now = [NSDate date];
	
	HKQuantity *energyQuantityConsumed = [HKQuantity quantityWithUnit:[HKUnit calorieUnit] doubleValue:foodItem.calories];
	
	HKQuantityType *energyConsumedType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
	
	HKQuantitySample *energyConsumedSample = [HKQuantitySample quantitySampleWithType:energyConsumedType quantity:energyQuantityConsumed startDate:now endDate:now];
	NSSet *energyConsumedSamples = [NSSet setWithObject:energyConsumedSample];
	
	HKCorrelationType *foodType = [HKObjectType correlationTypeForIdentifier:HKCorrelationTypeIdentifierFood];
	
	NSDictionary *foodCorrelationMetadata = @{HKMetadataKeyFoodType: foodItem.name};
	
	HKCorrelation *foodCorrelation = [HKCorrelation correlationWithType:foodType startDate:now endDate:now objects:energyConsumedSamples metadata:foodCorrelationMetadata];
	
	return foodCorrelation;
}


#pragma mark - Writing HealthKit Data

- (void)addFoodItemsToHealthKit:(NSArray *)foodItems {
	for(FoodItem *foodItem in foodItems) {
		HKCorrelation *foodCorrelationForFoodItem = [self foodCorrelationForFoodItem:foodItem];
		
		[self.healthStore saveObject:foodCorrelationForFoodItem withCompletion:^(BOOL success, NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (success) {
					[self.foodItems insertObject:foodItem atIndex:0];
				} else {
					NSLog(@"An error occured saving the food %@ The error was: %@.", foodItem.name, error);
					abort();
				}
			});
		}];
	}
}

- (void)updateUI {
	
	NSEnergyFormatter *energyFormatter = [self energyFormatter];
	
	self.activeBurnLabel.text = [energyFormatter stringFromValue:self.activeEnergyBurned unit:NSEnergyFormatterUnitCalorie];
	
	self.caloriesLabel.text = [energyFormatter stringFromValue:self.energyConsumed unit:NSEnergyFormatterUnitCalorie];

	self.netLabel.text = [energyFormatter stringFromValue:self.netEnergy unit:NSEnergyFormatterUnitCalorie];

}
- (void)refreshStatistics {
	HKQuantityType *energyConsumedType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
	HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
	
	[self fetchSumOfSamplesTodayForType:energyConsumedType unit:[HKUnit calorieUnit] completion:^(double totalJoulesConsumed, NSError *error) {
		[self fetchSumOfSamplesTodayForType:activeEnergyBurnType unit:[HKUnit jouleUnit] completion:^(double activeEnergyBurned, NSError *error) {
			
				dispatch_async(dispatch_get_main_queue(), ^{
					self.activeEnergyBurned = activeEnergyBurned;
					
					self.energyConsumed = totalJoulesConsumed;
					
					self.netEnergy = self.energyConsumed - self.activeEnergyBurned;
					
					[self updateUI];
				});
			}];
		}];
}

- (void)fetchSumOfSamplesTodayForType:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
	NSPredicate *predicate = [self predicateForSamplesToday];
	
	HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
		HKQuantity *sum = [result sumQuantity];
		
		if (completionHandler) {
			double value = [sum doubleValueForUnit:unit];
			completionHandler(value, error);
		}
	}];
	
	[self.healthStore executeQuery:query];
}

- (NSPredicate *)predicateForSamplesToday {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDate *now = [NSDate date];
	
	NSDate *startDate = [calendar startOfDayForDate:now];
	NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
	
	return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}


- (NSEnergyFormatter *)energyFormatter {
	static NSEnergyFormatter *energyFormatter;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		energyFormatter = [[NSEnergyFormatter alloc] init];
		energyFormatter.unitStyle = NSFormattingUnitStyleLong;
		energyFormatter.forFoodEnergyUse = YES;
		energyFormatter.numberFormatter.maximumFractionDigits = 2;
	});
	
	return energyFormatter;
}

@end
