//
//  MainViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/21/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

  @IBOutlet weak var dateNav: UINavigationItem!
  @IBOutlet weak var indicatorView: UIView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
    override func viewDidLoad() {
      super.viewDidLoad()
      indicatorView.layer.cornerRadius = 5
    }
  

}
