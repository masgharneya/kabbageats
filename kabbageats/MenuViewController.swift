//
//  MenuViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/18/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Hide bottom border on navigation bar
    for parent in self.navigationController!.navigationBar.subviews {
      for childView in parent.subviews {
        if(childView is UIImageView) {
          childView.removeFromSuperview()
        }
      }
    }
    
    // TODO: Add shadow for Date Navigation Bar
    
    
    
  }

}

