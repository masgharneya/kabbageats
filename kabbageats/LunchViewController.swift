//
//  LunchViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/18/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit
import Alamofire

class LunchViewController: UIViewController {

  @IBOutlet weak var mainDishLabel: UILabel!
  @IBOutlet weak var sideDishLabel: UILabel!
  @IBOutlet weak var lunchImage: UIImageView!
  @IBOutlet weak var dateNavBarTitle: UINavigationItem!
  @IBOutlet weak var activityIndicatorView: UIView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  var mainDish: String = ""
  var sideDish: String = ""
  var date: String = ""
  var lunchImgURL: String = ""
  var lunchImg: UIImage?
  var lunchIndex: Int = 0
  
  var downloadTask: NSURLSessionDownloadTask?
  var isLoading = false
  var lunchDate = NSDate()
  var lunches = [Lunch]()
  
  // MARK: - View Controller Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    //TODO: Hook up activity indicator

    //activityIndicatorView.layer.cornerRadius = 5
    //activityIndicatorView.hidden = true
    
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
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if !mainDish.isEmpty {
      mainDishLabel.text = mainDish
      sideDishLabel.text = sideDish
      if let url = NSURL(string: lunchImgURL) {
        downloadTask = lunchImage.loadImageWithURL(url)
      }
      // TODO: Update date in Navigation bar
    }
  }
  
  // MARK: - Actions
  /*
  @IBAction func refreshLunch(sender: UIBarButtonItem) {
    getLunch(lunch.date)
  }
  
  @IBAction func getNextLunch(sender: UISwipeGestureRecognizer) {
    if sender.direction == .Left {
      // Check if current day is Friday, if so skip to Monday
      if lunch.date.dayOfWeek() == 6 {
        updateDate(3)
      } else {
        updateDate(1)
      }
    } else if sender.direction == .Right {
      // Check if current day is Monday, if so skip to Friday
      if lunch.date.dayOfWeek() == 2 {
        updateDate(-3)
      } else {
        updateDate(-1)
      }
    }
  }
 */

}
