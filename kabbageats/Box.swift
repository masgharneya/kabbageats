//
//  Box.swift
//  kabbageats
//
//  Created by Marisa Toodle on 5/7/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import Foundation

final class Box<T> {
  let value: T
  
  init(value: T) {
    self.value = value
  }
}

enum Result<T> {
  case Success(Box<T>)
  case Failure(NSError)
}