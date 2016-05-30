//  Copyright © 2016 saranya.ravi@philips.com. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()
@property (nonatomic, assign) BOOL isHealthStoreAvailable;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateOfBirthLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.healthStore = [[HKHealthStore alloc] init];
	
	if ([HKHealthStore isHealthDataAvailable]) {
		
		[self.healthStore requestAuthorizationToShareTypes:nil readTypes:[self dataTypesToRead] completion:^(BOOL success, NSError *error) {
			if (!success) {
				NSLog(@"You didn't allow HealthKit to access these read data types. The error was: %@.", error);
				return;
			}
			else
			{
				self.isHealthStoreAvailable = YES;
			}
		}];
	}
	
	NSError *error;
	NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
	
	if (!dateOfBirth) {
		NSLog(@"Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.");
	}
	else {
		// Compute the age of the user.
		NSDate *now = [NSDate date];
		NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:NSCalendarWrapComponents];
		
		NSUInteger usersAge = [ageComponents year];
		self.ageLabel.text =  [NSString stringWithFormat:@"%lu",(unsigned long)usersAge];
		
		NSDateFormatter *dateFormatter = [NSDateFormatter new];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		self.dateOfBirthLabel.text = [dateFormatter stringFromDate:dateOfBirth];
	}
}

- (NSSet *)dataTypesToRead {
	HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
	return [NSSet setWithObjects: birthdayType, nil];
}

@end
