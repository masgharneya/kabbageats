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
  var fullMenu = ""
  var dishes: [String] {
    if !fullMenu.isEmpty {
      return fullMenu.componentsSeparatedByString("; ")
    }
    return [String]()
  }
  //var dishes = [String]()
  var imageURL = ""
  var image: UIImage?
  var date = ""
  var dateWithYear = ""
  

  let jsonFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(fullMenu, forKey: "FullMenu")
    aCoder.encodeObject(imageURL, forKey: "ImageURL")
    aCoder.encodeObject(date, forKey: "Date")
    aCoder.encodeObject(dateWithYear, forKey: "DateWithYear")
  }
  
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

  /*
  func getDishes() {
    if !fullMenu.isEmpty {
      dishes = fullMenu.componentsSeparatedByString("; ")
    }
  }
 */
  
  var sideDishes: String {
    return "with \(dishes[1]) and \(dishes[2])"
  }
  
}


