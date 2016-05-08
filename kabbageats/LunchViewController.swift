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
  
  var dishes = [String]()
  var mainDish = ""
  var sideDish = ""
  var date = ""
  var dateWithYear = ""
  var imageURL = ""
  var image: UIImage?
  var lunchIndex = 0
  var lunchDate = NSDate()
  
  // MARK: - View Controller Lifecycle
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
    
    // Load data
    if !mainDish.isEmpty {
      mainDishLabel.text = mainDish
      sideDishLabel.text = sideDish
      if image == nil {
        activityIndicator.startAnimating()
        indicatorView.hidden = false
        // TODO: Hide spinner if there is no image
        LunchKit.sharedInstance.getImage(imageURL, completion: {
          data in
          guard let img = UIImage(data: data) else { return }
          self.lunchImage.image = img
          self.image = img
          LunchKit.sharedInstance.lunches[self.lunchIndex].image = img
          self.activityIndicator.stopAnimating()
          self.indicatorView.hidden = true
        })
      } else {
        lunchImage.image = image
        self.activityIndicator.stopAnimating()
        self.indicatorView.hidden = true
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let mainVC = self.parentViewController?.parentViewController as? MainViewController {
      mainVC.dateNav.title = date
    }
    indicatorView.layer.cornerRadius = 5
    //activityIndicator.stopAnimating()
    //indicatorView.hidden = true
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "RateLunch" {
      let rateVC = segue.destinationViewController as! RateViewController
      rateVC.dishes = dishes
      rateVC.date = dateWithYear
    }
    if segue.identifier == "Comment" {
      let commentVC = segue.destinationViewController as! CommentViewController
      commentVC.date = dateWithYear
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
