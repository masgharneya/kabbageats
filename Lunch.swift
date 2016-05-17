//
//  Lunch.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/18/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import Foundation
import UIKit

class Lunch: NSObject, NSCoding {
  var date = ""
  var dateWithYear = ""
  var fullMenu = ""
  var imageURL = ""
  var image: UIImage?
  var dishes: [String] {
    if !fullMenu.isEmpty {
      return fullMenu.componentsSeparatedByString("; ")
    }
    return [String]()
  }
  
  var sideDishes: String {
    if dishes.count > 1 {
      return "with \(dishes[1]) and \(dishes[2])"
    } else {
      return ""
    }
  }
  
  let jsonFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
  
  required init?(coder aDecoder: NSCoder) {
    fullMenu = aDecoder.decodeObjectForKey("FullMenu") as! String
    imageURL = aDecoder.decodeObjectForKey("ImageURL") as! String
    date = aDecoder.decodeObjectForKey("Date") as! String
    dateWithYear = aDecoder.decodeObjectForKey("DateWithYear") as! String
    super.init()
  }
  
  override init() {
    super.init()
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(fullMenu, forKey: "FullMenu")
    aCoder.encodeObject(imageURL, forKey: "ImageURL")
    aCoder.encodeObject(date, forKey: "Date")
    aCoder.encodeObject(dateWithYear, forKey: "DateWithYear")
  }
  
  func scheduleNotification() {
    if let date = dateWithYear.getDateFromString() {
      if date.compare(NSDate()) != .OrderedAscending {
        let notifyDate = NSCalendar.currentCalendar().dateBySettingHour(10, minute: 0, second: 0, ofDate: date, options: .WrapComponents)
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = notifyDate
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.alertBody = fullMenu
        localNotification.userInfo = ["Date": dateWithYear]
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
      }
    }
  }
}


