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
  
  func jsonStringFromDate(date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.stringFromDate(date)
  }
  
}