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
  @IBOutlet weak var indicatorView: UIView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var menuView: UIView!
  
  var lunch: Lunch!
  var lunchIndex = 0
  
  // MARK: - View Controller Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    /*
    // Hide bottom border on navigation bar
    for parent in self.navigationController!.navigationBar.subviews {
      for childView in parent.subviews {
        if(childView is UIImageView) {
          childView.removeFromSuperview()
        }
      }
    }
 */
    
    // Load data
    if !lunch.dishes.isEmpty {
      mainDishLabel.text = lunch.dishes[0]
      sideDishLabel.text = lunch.sideDishes
      
      // If there is no image, show no image placeholder
      if lunch.imageURL == "404" {
        lunchImage.image = UIImage(named: "NoImage")
      } else {
        // If there is not an image, load image
        if lunch.image == nil {
          activityIndicator.startAnimating()
          indicatorView.hidden = false
          LunchKit.sharedInstance.getImage(lunch.imageURL, completion: {
            data in
            guard let img = UIImage(data: data) else { return }
            self.lunchImage.image = img
            self.lunch.image = img
            LunchKit.sharedInstance.lunches[self.lunchIndex].image = img
            self.activityIndicator.stopAnimating()
            self.indicatorView.hidden = true
          })
        } else {
          lunchImage.image = lunch.image
          activityIndicator.stopAnimating()
          indicatorView.hidden = true
        }
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let lunchPageVC = self.parentViewController as? LunchPageViewController {
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
