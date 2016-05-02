//
//  NSDate+GetWeekDay.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/19/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import Foundation

extension NSDate {
  func dayOfWeek() -> Int? {
    guard let cal: NSCalendar = NSCalendar.currentCalendar(),
      let comp: NSDateComponents = cal.components(.Weekday, fromDate: self) else { return nil }
    return comp.weekday
  }
  
  func apiDateStringFromDate() -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.stringFromDate(self)
  }
  
  func getNextWeekday() -> NSDate {
    if self.dayOfWeek() == 6 {
      return self.updateByNumOfDays(3)
    } else {
      return self.updateByNumOfDays(1)
    }
  }
  
  func updateByNumOfDays(numOfDays: Int) -> NSDate {
    let daysToAdd = NSDateComponents()
    daysToAdd.day = numOfDays
    guard let newDate = NSCalendar.currentCalendar().dateByAddingComponents(daysToAdd, toDate: self, options: .MatchNextTime) else {
      print("Invalid new date")
      return self
    }
    return newDate
  }
}