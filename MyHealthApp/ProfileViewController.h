//
//  ProfileViewController.h
//  MyHealthApp
//
//  Created by saranya.ravi@philips.com on 17/05/16.
//  Copyright © 2016 saranya.ravi@philips.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@import HealthKit;

@interface ProfileViewController : UIViewController
@property (nonatomic) HKHealthStore *healthStore;
@end
