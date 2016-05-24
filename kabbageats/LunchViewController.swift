//
//  LunchViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/18/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit

class LunchViewController: UIViewController {

  @IBOutlet weak var mainDishLabel: UILabel!
  @IBOutlet weak var sideDishLabel: UILabel!
  @IBOutlet weak var lunchImage: UIImageView!
  @IBOutlet weak var indicatorView: UIView! // Take a look at github projects like SVProgressHUD or Kabbage to see how they present indicators. Nothing wrong with they way its implemented, but it would be hard to reuse in other ViewControllers
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var menuView: UIView!
  
  var lunch: Lunch!
  var lunchIndex = 0
  
  // MARK: - View Controller Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Load data
    if !lunch.dishes.isEmpty {
      mainDishLabel.text = lunch.dishes[0]
      sideDishLabel.text = lunch.sideDishes
      
      // If there is no image, show no image placeholder
      if lunch.imageURL == "404" { // 404 imageURL?
        lunchImage.image = UIImage(named: "NoImage")
      } else {
        // If there is not an image, load image
        if lunch.image == nil {
          activityIndicator.startAnimating()
          indicatorView.hidden = false
          LunchKit.sharedInstance.getImage(lunch.imageURL, completion: {
            data in
            guard let img = UIImage(data: data) else {
              self.lunchImage.image = UIImage(named: "NoImage")
              self.hideIndicator()
              return
            }
            self.lunchImage.image = img
            self.lunch.image = img
            LunchKit.sharedInstance.lunches[self.lunchIndex].image = img
            self.hideIndicator()
          })
        } else {
          lunchImage.image = lunch.image
          hideIndicator()
        }
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let lunchPageVC = self.parentViewController as? LunchPageViewController {
      // Might want to rethink how to do this. Your LunchViewController not only needs to know about itself, but the LunchPageViewController and the MainViewController. Let me know if you want some ideas on how to do this.
      lunchPageVC.parentController.dateNav.title = lunch.date
    }
    indicatorView.layer.cornerRadius = 5
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "RateLunch" {
      let rateVC = segue.destinationViewController as! RateViewController
      rateVC.dishes = lunch.dishes
      rateVC.date = lunch.dateWithYear
    }
    if segue.identifier == "Comment" {
      let commentVC = segue.destinationViewController as! CommentViewController
      commentVC.date = lunch.dateWithYear
    }
  }
  
  func hideIndicator() {
    activityIndicator.stopAnimating()
    indicatorView.hidden = true
  }
  
  @IBAction func rateLunch(sender: UIButton) {
    performSegueWithIdentifier("RateLunch", sender: sender)
  }
  
  // MARK: - Actions
  /*
  @IBAction func refreshLunch(sender: UIBarButtonItem) {
    getLunch(lunch.date)
  }
 */

}
