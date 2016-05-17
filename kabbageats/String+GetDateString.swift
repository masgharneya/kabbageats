//
//  String+GetDateString.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/27/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import Foundation

extension String {
  
  func getDateFromString() -> NSDate? {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
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
      let strFormatter = NSDateFormatter()
      strFormatter.dateFormat = "EEEE, MMMM d"
      return strFormatter.stringFromDate(date)
    }
    return self
  }
  
  func getJSONStringFromString() -> String {
    if let date = self.getNextDateFromString() {
      return date.getStringFromDate()
    }
    return self
  }
}