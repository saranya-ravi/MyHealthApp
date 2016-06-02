
#import "FoodItem.h"

@interface FoodItem ()

@property (nonatomic, readwrite) double calories;
@property (nonatomic, readwrite, copy) NSString *name;

@end

@implementation FoodItem

+ (instancetype)foodItemWithName:(NSString *)name calories:(double)calories {
    FoodItem *foodItem = [[self alloc] init];
    
    foodItem.name = name;
    foodItem.calories = calories;

    return foodItem;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[FoodItem class]]) {
        return [object calories] == self.calories && [self.name isEqualToString:[object name]];
    }
    
    return NO;
}

- (NSString *)description {
    return [@{
        @"name": self.name,
        @"calories": @(self.calories)
    } description];
}

@end
