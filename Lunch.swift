//
//  Lunch.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/18/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import Foundation
import UIKit

struct Lunch {
  var date = NSDate()
  var fullMenu = ""
  var mainDish = ""
  var dishes = [String]()
  var imageURL = ""
  var image = UIImage()
  var ratings = [String: AnyObject]()
  var comments = [String: AnyObject]()
  
  let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter
  }()
  
  let jsonFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
 
  
  mutating func getDishes() {
    if !fullMenu.isEmpty {
      dishes = fullMenu.componentsSeparatedByString("; ")
      mainDish = dishes[0]
    }
  }
  
  var sideDishes: String {
    return "with \(dishes[1]) and \(dishes[2])"
  }
  
  var todayString: String {
    return dateFormatter.stringFromDate(date)
  }
  
  var jsonDateString: String {
    return jsonFormatter.stringFromDate(date)
  }
}


