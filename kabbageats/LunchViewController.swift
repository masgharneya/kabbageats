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
  var lunchIndex: Int = 0
  
  var downloadTask: NSURLSessionDownloadTask?
  var isLoading = false
  var lunchDate = NSDate()
  var lunches = [Lunch]()
  
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
    
    activityIndicatorView.layer.cornerRadius = 5
    activityIndicatorView.hidden = true
    setStartDate()
    getLunches()
    
    //self.dateNavBarTitle.title = lunches[0].todayString
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
  
  func getLunches() {
    // Make Get Request
      let dateStr = lunchDate.jsonStringFromDate(lunchDate)
      print("Date Str: \(dateStr)")
      Manager.request(.GET, "http://lunch.kabbage.com/api/v2/lunches/\(dateStr)/").validate().responseJSON {
        response in
        print(response)
        guard response.result.isSuccess else {
          self.showNetworkError()
          print("Error while retrieving lunch: \(response.result.error)")
          self.hideActivityIndicator()
          return
        }
        
        // Parse JSON
        guard let lunchDict = response.result.value as? [String: AnyObject],
          date = lunchDict["date"] as? String,
          menu = lunchDict["menu"] as? String,
          image = lunchDict["image"] as? String else {
            self.showNetworkError()
            print("Received data not in the correct format")
            return
        }
        
        // Set lunch properties
        var lunch = Lunch()
        lunch.date = date
        lunch.fullMenu = menu
        lunch.imageURL = image
        print(lunch)
        lunch.getDishes()
        print("Lunch: \(lunch)")
        
        dispatch_async(dispatch_get_main_queue()) {
          self.lunches.append(lunch)
          print("Lunches: \(self.lunches.count)")
          self.lunchDate = self.getNextWeekday(self.lunchDate)
          if self.lunches.count < 5 {
            self.getLunches()
          } else {
            self.mainDishLabel.text = self.lunches[2].dishes[0]
            self.sideDishLabel.text = self.lunches[2].sideDishes
            if let url = NSURL(string: self.lunches[2].imageURL) {
              self.downloadTask = self.lunchImage.loadImageWithURL(url)
            }
            self.dateNavBarTitle.title = self.lunches[2].todayString

          }
        }
      }
    
  }
  
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
  
  func showNetworkError() {
    let alert = UIAlertController(title: "Whoops...", message: "There was an error retrieving lunch.", preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(action)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func hideActivityIndicator() {
    activityIndicator.stopAnimating()
    activityIndicatorView.hidden = true
  }
  
  func setStartDate() {
    // if Monday, set start day at Thursday
    if lunchDate.dayOfWeek() == 2 {
      lunchDate = updateDate(lunchDate, numOfDays: -4)
      
      // if Tuesday, set start day at Friday
    } else if lunchDate.dayOfWeek() == 3 {
      lunchDate = updateDate(lunchDate, numOfDays: -3)
      
      // Otherwise, set start day two days back
    } else {
      lunchDate = updateDate(lunchDate, numOfDays: -2)
    }
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

