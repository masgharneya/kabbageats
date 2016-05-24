//
//  String+GetDateString.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/27/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import Foundation

// Might also be good to make a static date formatter for these

extension String {
  
  func getDateFromString() -> NSDate? {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
    return dateFormatter.dateFromString(self)
  }
  
  func getNextDateFromString() -> NSDate? {
    if let date = self.getDateFromString() {
      return date.getNextWeekday()
    }
    return nil
  }
  
  func getTodayString() -> String {
    if let date = self.getDateFromString() {
      // Convert date to sentence string
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "EEEE, MMMM d"
      return dateFormatter.stringFromDate(date)
    }
    return self
  }
}