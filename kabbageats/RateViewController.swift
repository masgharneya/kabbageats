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
  
  // MARK: - Methods
  
  func updateUI() {
    mainDishLabel.text = dishes[0]
    sideDish1Label.text = dishes[1]
    sideDish2Labael.text = dishes[2]
  }
  
  func displayRateResult(result: Result<Bool>, id: String, button: UIButton) {
    switch result {
    case .Success(_):
      // Highlight button if rating is successful
      if id.rangeOfString("Up") != nil {
        button.setImage(UIImage(named: "ThumbsUpHighlighted"), forState: .Normal)
      } else if id.rangeOfString("Down") != nil {
        button.setImage(UIImage(named: "ThumbsDownHighlighted"), forState: .Normal)
      }
      // TODO: Disable button if already voted
    case .Failure(_):
      break
      // TODO: Show error if failure
    }
  }
  
  // MARK: - Actions

  @IBAction func upRate(sender: UIButton) {
    // TODO: Show indicator and disable button while in progress
    if let id = sender.accessibilityIdentifier {
      switch id {
      case "ThumbsUpMain":
        LunchKit.sharedInstance.upRateDish(dishes[0], date: date, completion:  {
          result in
          self.displayRateResult(result, id: id, button: sender)
        })
      case "ThumbsUpSide1":
        LunchKit.sharedInstance.upRateDish(dishes[1], date: date, completion:  {
          result in
          self.displayRateResult(result, id: id, button: sender)
        })
      case "ThumbsUpSide2":
        LunchKit.sharedInstance.upRateDish(dishes[2], date: date, completion:  {
          result in
          self.displayRateResult(result, id: id, button: sender)
        })
      default:
        break
      }
    }
  }
  
  @IBAction func downRate(sender: UIButton) {
    if let id = sender.accessibilityIdentifier {
      switch id {
      case "ThumbsDownMain":
        LunchKit.sharedInstance.downRateDish(dishes[0], date: date, completion: {
          result in
          self.displayRateResult(result, id: id, button: sender)
        })
      case "ThumbsDownSide1":
        LunchKit.sharedInstance.downRateDish(dishes[1], date: date, completion: {
          result in
          self.displayRateResult(result, id: id, button: sender)
        })
      case "ThumbsDownSide2":
        LunchKit.sharedInstance.downRateDish(dishes[2], date: date, completion: {
          result in
          self.displayRateResult(result, id: id, button: sender)
        })
      default:
        break
      }
    }
  }
  
  @IBAction func close() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - EXTENSIONS

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