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
  
  // Highlight button if rating is successful
  func updateRateButton(id: String, button: UIButton) {
    if id.rangeOfString("Up") != nil {
      button.setImage(UIImage(named: "ThumbsUpHighlighted"), forState: .Normal)
    } else {
      button.setImage(UIImage(named: "ThumbsDownHighlighted"), forState: .Normal)
    }
  }
  
  // MARK: - Actions

  @IBAction func upVote(sender: UIButton) {
    if let id = sender.accessibilityIdentifier {
      switch id {
      case "ThumbsUpMain":
        LunchKit.sharedInstance.upVoteDish(dishes[0], date: date, completion:  {
          self.updateRateButton(id, button: sender)
        })
      case "ThumbsUpSide1":
        LunchKit.sharedInstance.upVoteDish(dishes[1], date: date, completion:  {
          self.updateRateButton(id, button: sender)
        })
      default:
        LunchKit.sharedInstance.upVoteDish(dishes[2], date: date, completion:  {
          self.updateRateButton(id, button: sender)
        })
      }
    }
  }
  
  @IBAction func downVote(sender: UIButton) {
    if let id = sender.accessibilityIdentifier {
      switch id {
      case "ThumbsDownMain":
        LunchKit.sharedInstance.downVoteDish(dishes[0], date: date, completion: {
          self.updateRateButton(id, button: sender)
        })
      case "ThumbsDownSide1":
        LunchKit.sharedInstance.downVoteDish(dishes[1], date: date, completion: {
          self.updateRateButton(id, button: sender)
        })
      default:
        LunchKit.sharedInstance.downVoteDish(dishes[2], date: date, completion: {
          self.updateRateButton(id, button: sender)
        })
      }
    }
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