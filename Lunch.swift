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
  var fullMenu = ""
  var dishes = [String]()
  var imageURL = ""
  var image = UIImageView()
  var ratings = [String: AnyObject]()
  var comments = [String: AnyObject]()
  var date = ""
  
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
    }
  }
  
  var sideDishes: String {
    return "with \(dishes[1]) and \(dishes[2])"
  }
  
  var todayString: String {
    return dateFormatter.stringFromDate(NSDate())
  }
  /*
  var jsonDateString: String {
    return jsonFormatter.stringFromDate(date_)
  }
 */
}


