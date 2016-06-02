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
	
	@IBOutlet var activityRing: WKInterfaceActivityRing!
	
	override func willActivate() {
		super.willActivate()
		getData()
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
		
		// Build the query
		let query = HKActivitySummaryQuery(predicate: summariesWithinRange) { (query, summaries, error) -> Void in
			guard let activitySummaries = summaries else {
				guard error != nil else {
					fatalError("*** Did not return a valid error object. ***")
				}
				
				// Handle the error here...
				return
			}
			NSLog("%@", activitySummaries)
			self.activityRing.setActivitySummary(activitySummaries[0], animated: true)		}

		// Run the query
		healthStore.executeQuery(query)
	}
}