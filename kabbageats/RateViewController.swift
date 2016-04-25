//
//  RateViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/24/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit
import Alamofire

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
  

  
  func upVoteDish(dish: String, button: UIButton) {
    let params: [String : AnyObject] = [
      "dish": "\(dish)",
      "rating": 1,
      "source": "iOS App"
    ]
    
    Manager.request(.POST, "https://lunch.kabbage.com/api/v2/lunches/\(date)/ratings", parameters: params).response {
      request, response, data, error in
      if response?.statusCode == 204 {
        button.setImage(UIImage(named: "ThumbsUpHighlighted"), forState: .Normal)
      }
    }
  }
  
  func downVoteDish(dish: String, button: UIButton) {
    let params: [String : AnyObject] = [
      "dish": "\(dish)",
      "rating": -1,
      "source": "iOS App"
    ]
    
    Manager.request(.POST, "https://lunch.kabbage.com/api/v2/lunches/\(date)/ratings", parameters: params).response {
      request, response, data, error in
      if response?.statusCode == 204 {
         button.setImage(UIImage(named: "ThumbsDownHighlighted"), forState: .Normal)
      }
    }
  }
  
  @IBAction func upVote(sender: UIButton) {
    if let id = sender.accessibilityIdentifier {
      switch id {
      case "ThumbsUpMain":
        upVoteDish(dishes[0], button: sender)
      case "ThumbsUpSide1":
        upVoteDish(dishes[1], button: sender)
      default:
        upVoteDish(dishes[2], button: sender)
      }
    }
  }
  
  @IBAction func downVote(sender: UIButton) {
    if let id = sender.accessibilityIdentifier {
      switch id {
      case "ThumbsDownMain":
        downVoteDish(dishes[0], button: sender)
      case "ThumbsDownSide1":
        downVoteDish(dishes[1], button: sender)
      default:
        downVoteDish(dishes[2], button: sender)
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

// Server Trust Policy Manager for Alamofire (to accept self-signed certificate, from http://stackoverflow.com/questions/31945078/how-to-connect-to-self-signed-servers-using-alamofire-1-3 )
private var Manager : Alamofire.Manager = {
  // Create the server trust policies
  let serverTrustPolicies: [String: ServerTrustPolicy] = [
    "lunch.kabbage.com": .DisableEvaluation
  ]
  
  // Create custom manager
  let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
  configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
  let man = Alamofire.Manager(
    configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
    serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
  )
  return man
}()