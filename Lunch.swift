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
  var date = ""
  var fullMenu = ""
  var mainDish = ""
  var dishes = [String]()
  var imageURL = ""
  var image = UIImage()
  var ratings = [String: AnyObject]()
  var comments = [String: AnyObject]()
  
  mutating func getDishes() {
    if !fullMenu.isEmpty {
      dishes = fullMenu.componentsSeparatedByString("; ")
      mainDish = dishes[0]
    }
  }
  
  var sideDishes: String {
    return "with \(dishes[1]) and \(dishes[2])"
  }
}


