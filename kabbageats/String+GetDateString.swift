//
//  String+GetDateString.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/27/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import Foundation

extension String {
  func getNextDateFromString() -> NSDate? {
    // Convert string to a date
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    if let date = dateFormatter.dateFromString(self) {
      return date.getNextWeekday()
    }
    return nil
  }
  
  func getTodayString() -> String {
    // Convert string to a date
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter.dateFromString(self)
    
    if let date = date {
      // Convert date to sentence string
      let strFormatter = NSDateFormatter()
      strFormatter.dateFormat = "EEEE, MMMM d"
      return strFormatter.stringFromDate(date)
    }
    return self
  }
  
  func getJSONStringFromString() -> String {
    // Convert string to date
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    if let date = dateFormatter.dateFromString(self) {
      let nextDate = date.getNextWeekday()
      
      return nextDate.apiDateStringFromDate()
    }
    return self
  }
}