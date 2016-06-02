//
//  ActivityController.swift
//  MyHealthApp
//
//  Created by mark.mulder@philips.com on 02/06/16.
//  Copyright © 2016 saranya.ravi@philips.com. All rights reserved.
//

import Foundation
import WatchKit
import HealthKit

class ActivityController: WKInterfaceController {
	let healthStore = HKHealthStore()
	var query : HKActivitySummaryQuery?
	
	@IBOutlet var activityRing: WKInterfaceActivityRing!
	
	override func willActivate() {
		super.willActivate()
		let summary = HKActivitySummary();
		summary.activeEnergyBurned = HKQuantity(unit: HKUnit.calorieUnit(), doubleValue: 30)
		summary.activeEnergyBurnedGoal = HKQuantity(unit: HKUnit.calorieUnit(), doubleValue: 70)
		summary.appleExerciseTime = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: 70)
		summary.appleExerciseTimeGoal = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: 140)
		self.activityRing.setActivitySummary(summary, animated: true)
	}
	
	
	func getData(){
		guard let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) else {
			fatalError("*** This should never fail. ***")
		}
		
		let endDate = NSDate()
		
		guard let startDate = calendar.dateByAddingUnit(.Day, value: -7, toDate: endDate, options: []) else {
			fatalError("*** unable to calculate the start date ***")
		}
		
		let units: NSCalendarUnit = [.Day, .Month, .Year, .Era]
		
		let startDateComponents = calendar.components(units, fromDate: startDate)
		startDateComponents.calendar = calendar
		
		let endDateComponents = calendar.components(units, fromDate:endDate)
		endDateComponents.calendar = calendar

		
		// Create the predicate for the query
		let summariesWithinRange = HKQuery.predicateForActivitySummariesBetweenStartDateComponents(startDateComponents, endDateComponents: endDateComponents)
		
		let typesToRead = Set([HKObjectType.activitySummaryType(),
			HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!])
		
		healthStore.requestAuthorizationToShareTypes(nil, readTypes: typesToRead) { success, error in
			if let error = error where !success {
				print("You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: \(error.localizedDescription). If you're using a simulator, try it on a device.")
			}
		}

		
		// Build the query
		query = HKActivitySummaryQuery(predicate: summariesWithinRange) { (query, summaries, error) -> Void in
			guard summaries != nil else {
				guard error != nil else {
					fatalError("*** Did not return a valid error object. ***")
				}
				
				// Handle the error here...
				
				return
			}
			
			// Do something with the summaries here...
			self.activityRing.setActivitySummary(self.giveSummaryTotal(summaries), animated: true)

		}
		healthStore.executeQuery(query!)
	}
	
	func giveSummaryTotal(summaries : [HKActivitySummary]?) -> HKActivitySummary{
		var activeEnergyBurned = 0.0
		var activeEnergyBurnedGoal = 0.0
		var appleExerciseTime = 0.0
		var appleExerciseTimeGoal = 0.0

		let totalSummary = HKActivitySummary();
		for summary in summaries!{
			activeEnergyBurned += summary.activeEnergyBurned.doubleValueForUnit(HKUnit.calorieUnit())
			activeEnergyBurnedGoal += summary.activeEnergyBurnedGoal.doubleValueForUnit(HKUnit.calorieUnit())
			appleExerciseTime += summary.appleExerciseTime.doubleValueForUnit(HKUnit.secondUnit())
			appleExerciseTimeGoal += summary.appleExerciseTimeGoal.doubleValueForUnit(HKUnit.secondUnit())
		}
		totalSummary.activeEnergyBurned = HKQuantity(unit: HKUnit.calorieUnit(), doubleValue: activeEnergyBurned)
		totalSummary.activeEnergyBurnedGoal = HKQuantity(unit: HKUnit.calorieUnit(), doubleValue: activeEnergyBurnedGoal)
		totalSummary.appleExerciseTime = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: appleExerciseTime)
		totalSummary.appleExerciseTimeGoal = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: appleExerciseTimeGoal)
		return totalSummary
	}
	
	@IBAction func fetchData() {
		getData()
	}
}