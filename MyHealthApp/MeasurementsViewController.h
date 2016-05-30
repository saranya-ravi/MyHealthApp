//
//  MeasurementsViewController.h
//  MyHealthApp
//
//  Created by saranya.ravi@philips.com on 29/05/16.
//  Copyright © 2016 saranya.ravi@philips.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@import HealthKit;

@interface MeasurementsViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic) HKHealthStore *healthStore;
@end
