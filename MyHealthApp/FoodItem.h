
@import Foundation;
@import HealthKit;

@interface FoodItem : NSObject

+ (instancetype)foodItemWithName:(NSString *)name calories:(double)calories;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) double calories;

@end
