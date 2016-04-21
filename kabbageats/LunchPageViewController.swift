//
//  MenuPageViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/20/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit
import Alamofire

class LunchPageViewController: UIPageViewController {
  var lunches = [Lunch]()
  var currentIndex: Int!
  var lunchDate = NSDate()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setStartDate()
    getLunches()
    
    dataSource = self
    
  }
  
  func lunchViewController(index: Int) -> LunchViewController? {
    if let lunch = storyboard?.instantiateViewControllerWithIdentifier("LunchViewController") as? LunchViewController {
      lunch.date = lunches[index].date
      lunch.mainDish = lunches[index].dishes[0]
      lunch.sideDish = lunches[index].sideDishes
      lunch.lunchImgURL = lunches[index].imageURL
      //if let url = NSURL(string: self.lunches[2].imageURL) {
        //self.downloadTask = self.lunchImage.loadImageWithURL(url)
      //}
      lunch.lunchIndex = index
      //self.dateNavBarTitle.title = self.lunches[2].todayString
      return lunch
    }
    return nil
  }
  
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
        //self.hideActivityIndicator()
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
      //print(lunch)
      lunch.getDishes()
      
      dispatch_async(dispatch_get_main_queue()) {
        self.lunches.append(lunch)
        print("Lunches: \(self.lunches.count)")
        self.lunchDate = self.getNextWeekday(self.lunchDate)
        if self.lunches.count < 5 {
          self.getLunches()
        } else {
          self.currentIndex = 3
          if let viewController = self.lunchViewController(self.currentIndex ?? 0) {
            let viewControllers = [viewController]
            self.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
          }
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
  
  func showNetworkError() {
    let alert = UIAlertController(title: "Whoops...", message: "There was an error retrieving lunch.", preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(action)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  /*
  func hideActivityIndicator() {
    activityIndicator.stopAnimating()
    activityIndicatorView.hidden = true
  }
 */

}

extension LunchPageViewController: UIPageViewControllerDataSource {
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    if let viewController = viewController as? LunchViewController {
      var index = viewController.lunchIndex
      guard index != NSNotFound && index != 0 else { return nil }
      index = index - 1
      return lunchViewController(index)
    }
    return nil
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    if let viewController = viewController as? LunchViewController {
      var index = viewController.lunchIndex
      guard index != NSNotFound else { return nil }
      index = index + 1
      guard index != lunches.count else { return nil }
      return lunchViewController(index)
    }
    return nil
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
