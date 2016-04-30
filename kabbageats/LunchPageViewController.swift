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
  var isLoading = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setStartDate()
    isLoading = true
    showLoading()
    loadLunches()
    
    dataSource = self
  }
  
  func lunchViewController(index: Int) -> LunchViewController? {
    if let lunch = storyboard?.instantiateViewControllerWithIdentifier("LunchViewController") as? LunchViewController {
      lunch.date = lunches[index].date
      lunch.dateWithYear = lunches[index].dateWithYear
      lunch.dishes = lunches[index].dishes
      lunch.mainDish = lunches[index].dishes[0]
      lunch.sideDish = lunches[index].sideDishes
      lunch.imageURL = lunches[index].imageURL
      lunch.image = lunches[index].image
      lunch.lunchIndex = index
      return lunch
    }
    return nil
  }
  
  func loadLunches() {
    // Make Get Request
    //let dateStr = lunchDate.apiDateStringFromDate()
    isLoading = true
    LunchKit.sharedInstance.getLunches(lunchDate, completion: {
      self.lunches = LunchKit.sharedInstance.lunches
      self.currentIndex = 0
      if let viewController = self.lunchViewController(self.currentIndex ?? 0) {
        let viewControllers = [viewController]
        self.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
      }
      self.isLoading = false
      self.showLoading()
    })
  }
  
  func getNextLunch(index: Int) {
    // Make Get Request
    let lastDayInArray = lunches[lunches.count - 1].dateWithYear
    let dateStr = lastDayInArray.getJSONStringFromString()
    isLoading = true
    
    // TODO: Extract Get Request to separate method for use here and in getLunches method
    Manager.request(.GET, "http://lunch.kabbage.com/api/v2/lunches/\(dateStr)/").validate().responseJSON {
      response in
      print(response)
      guard response.result.isSuccess else {
        if let lunch = self.viewControllers![self.viewControllers!.count - 1] as? LunchViewController {
          lunch.activityIndicator.stopAnimating()
          lunch.indicatorView.hidden = true
        }
        print("Error while retrieving lunch: \(response.result.error)")
        return
      }
      
      // Parse JSON
      guard let lunchDict = response.result.value as? [String: AnyObject],
        date = lunchDict["date"] as? String,
        menu = lunchDict["menu"] as? String,
        imageURL = lunchDict["image"] as? String else {
          self.showNetworkError()
          print("Received data not in the correct format")
          return
      }
      
      // Set lunch properties
      var lunch = Lunch()
      lunch.dateWithYear = date
      lunch.date = date.getTodayString()
      lunch.fullMenu = menu
      lunch.imageURL = imageURL
      // Download Image
      if let url = NSURL(string: imageURL), data = NSData(contentsOfURL: url) {
        lunch.image = UIImage(data: data)!
      }
      lunch.getDishes()
      self.lunches.append(lunch)
      
      self.isLoading = false
      if let viewController = self.lunchViewController(index - 1) {
        let viewControllers = [viewController]
        self.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
      }
    }
  }
  
  // MARK: - Helper Methods
  func setStartDate() {
    // if Sunday, set start day at Friday
    if lunchDate.dayOfWeek() == 1 {
      lunchDate.updateByNumOfDays(-2)
      
      // if Monday, set start day at Friday
    } else if lunchDate.dayOfWeek() == 2 {
      lunchDate.updateByNumOfDays(-3)
      
      // Otherwise, set start day one day back
    } else {
      lunchDate.updateByNumOfDays(-1)
    }
  }

  func showNetworkError() {
    let alert = UIAlertController(title: "Whoops...", message: "There was an error retrieving lunch.", preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(action)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func showLoading() {
    if let mainVC = self.parentViewController as? MainViewController {
      if isLoading {
        mainVC.activityIndicator.startAnimating()
        mainVC.activityIndicator.hidden = false
      } else {
        mainVC.activityIndicator.stopAnimating()
        mainVC.indicatorView.hidden = true
      }
    }
  }
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
      if index == lunches.count {
        getNextLunch(index)
        viewController.activityIndicator.startAnimating()
        viewController.indicatorView.hidden = false
      } else {
        return lunchViewController(index)
      }
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
