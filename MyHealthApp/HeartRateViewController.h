//
//  HeartRateViewController.h
//  MyHealthApp
//
//  Created by saranya.ravi@philips.com on 01/06/16.
//  Copyright © 2016 saranya.ravi@philips.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@import HealthKit;

@interface HeartRateViewController : UIViewController
@property (nonatomic) HKHealthStore *healthStore;
@end
