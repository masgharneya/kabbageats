//
//  RateViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/24/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit

class RateViewController: UIViewController {
  
  // Might be cool to put these labels in a stackView or a tableView. That way you can dynamically create as many dish ratings that you need, instead of hardcoding 1 main, 2 side
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
  
  // MARK: - Actions

  @IBAction func rateDish(sender: UIButton) {
    // TODO: Show indicator and disable button while in progress
    var rating: Int
    var dish = ""
    if let id = sender.accessibilityIdentifier {
      // If up vote, set rating to 1, else -1
      if id.rangeOfString("Up") != nil {
        rating = 1
      } else {
        rating = -1
      }
      
      // Get dish string based on selection
      switch id {
      case "ThumbsUpMain", "ThumbsDownMain":
        dish = dishes[0]
      case "ThumbsUpSide1", "ThumbsDownSide1":
        dish = dishes[1]
      case "ThumbsUpSide2", "ThumbsDownSide2":
        dish = dishes[2]
      default:
        break
      }
      
      // Make post call with dish and rating
      LunchKit.sharedInstance.postDishRating(dish, date: date, rating: rating, completion:  {
        result in
        switch result {
        case .Success(_):
          // Change button color based on post success/failure
          if id.rangeOfString("Up") != nil {
            sender.setImage(UIImage(named: "ThumbsUpHighlighted"), forState: .Normal)
          } else if id.rangeOfString("Down") != nil {
            sender.setImage(UIImage(named: "ThumbsDownHighlighted"), forState: .Normal)
          }
        // TODO: Disable button if already voted
        case .Failure(_):
          break
          // TODO: Show error if failure
        }
      })
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