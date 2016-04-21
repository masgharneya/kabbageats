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
  
  var mainDish: String = ""
  var sideDish: String = ""
  var date: String = ""
  var lunchImgURL: String = ""
  var lunchIndex: Int = 0
  
  var downloadTask: NSURLSessionDownloadTask?
  var isLoading = false
  var lunchDate = NSDate()
  var lunches = [Lunch]()
  
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
    
    //activityIndicatorView.layer.cornerRadius = 5
    //activityIndicatorView.hidden = true
    
    //self.dateNavBarTitle.title = lunches[0].todayString
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    //mainDishLabel.text = mainDish
    //sideDishLabel.text = sideDish
    //if let url = NSURL(string: lunchImgURL) {
      //downloadTask = lunchImage.loadImageWithURL(url)
    //}
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
  
  // MARK: - Methods
  func getLunch(date: NSDate) {
    downloadTask?.cancel()
    activityIndicatorView.hidden = false
    activityIndicator.startAnimating()
    let dateStr = lunch.jsonDateString
    Manager.request(.GET, "http://lunch.kabbage.com/api/v2/lunches/\(dateStr)/").validate().responseJSON {
      response in
      guard response.result.isSuccess else {
        self.showNetworkError()
        print("Error while retrieving lunch: \(response.result.error)")
        self.hideActivityIndicator()
        return
      }
      
      guard let lunchDict = response.result.value as? [String: AnyObject],
        menu = lunchDict["menu"] as? String,
        image = lunchDict["image"] as? String else {
          print("Received data not in the correct format")
          return
      }
      
      // Set lunch properties
      self.lunch.fullMenu = menu
      self.lunch.imageURL = image
      print(self.lunch)
      self.lunch.getDishes()
      
      // Update UI
      dispatch_async(dispatch_get_main_queue()) {
        self.hideActivityIndicator()
        self.mainDishLabel.text = self.lunch.dishes[0]
        self.sideDishLabel.text = self.lunch.sideDishes
        if let url = NSURL(string: self.lunch.imageURL) {
          self.downloadTask = self.lunchImage.loadImageWithURL(url)
        }
        self.dateNavBarTitle.title = self.lunch.todayString
      }
    }
  }
 */
  
  
  func getNextWeekday(date: NSDate) -> NSDate {
    if date.dayOfWeek() == 6 {
      return updateDate(date, numOfDays: 3)
    } else {
      return updateDate(date, numOfDays: 1)
    }
  }
  
  func updateDate(date: NSDate, numOfDays: Int) -> NSDate {
    let daysToAdd = NSDateComponents()
    daysToAdd.day = numOfDays
    guard let newDate = NSCalendar.currentCalendar().dateByAddingComponents(daysToAdd, toDate: date, options: .MatchNextTime) else {
      print("Invalid new date")
      return date }
    
    return newDate
    //lunch.date = tomorrow
    //getLunch(lunch.date)
  }
  
  

}
