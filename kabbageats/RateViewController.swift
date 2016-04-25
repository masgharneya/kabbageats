//
//  RateViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/24/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit

class RateViewController: UIViewController {
  
  @IBOutlet weak var mainDishLabel: UILabel!
  @IBOutlet weak var sideDish1Label: UILabel!
  @IBOutlet weak var sideDish2Labael: UILabel!
  @IBOutlet weak var popupView: UIView!
  var dishes = [String]()
  var date = ""
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    modalPresentationStyle = .Custom
    transitioningDelegate = self
  }
  
  override func viewDidLoad() {
      super.viewDidLoad()
    popupView.layer.cornerRadius = 10
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RateViewController.close))
    gestureRecognizer.cancelsTouchesInView = false
    gestureRecognizer.delegate = self
    view.addGestureRecognizer(gestureRecognizer)
    
    if dishes.count == 3 {
      updateUI()
    }
  }
  
  
  func updateUI() {
    mainDishLabel.text = dishes[0]
    sideDish1Label.text = dishes[1]
    sideDish2Labael.text = dishes[2]
  }
  
  @IBAction func close() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  
}

extension RateViewController: UIViewControllerTransitioningDelegate {
  func presentationControllerForPresentedViewController(
    presented: UIViewController,
    presentingViewController presenting: UIViewController,
    sourceViewController source: UIViewController)
    -> UIPresentationController? {
      
    return DimmingPresentationController(presentedViewController: presented,
                                          presentingViewController: presenting)
  }
}

extension RateViewController: UIGestureRecognizerDelegate {
  // Close popup view if user taps outside of popup. Function returns true only if the user taps on the background and false if user taps inside the popup.
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    return (touch.view === self.view)
  }
}