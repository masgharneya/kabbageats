//
//  MenuPageViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/20/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit

class LunchPageViewController: UIPageViewController {
  var lunches: [Lunch]
  var currentIndex: Int!
  var lunchDate = NSDate()
  var isLoading = false
  var parentController: MainViewController!
  
  required init?(coder aDecoder: NSCoder) {
    lunches = [Lunch]()
    super.init(coder: aDecoder)
    
    print(dataFilePath())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setStartDate()
    //lunchDate = setSpecificDate()
    loadLunches()
    
    dataSource = self
  }
  
  // MARK: Methods
  func lunchViewController(index: Int) -> LunchViewController? {
    if let lunchVC = storyboard?.instantiateViewControllerWithIdentifier("LunchViewController") as? LunchViewController {
      lunchVC.lunch = lunches[index]
      lunchVC.lunchIndex = index
      return lunchVC
    }
    return nil
  }
  
  func getLunches() {
    // Make Get Request
    isLoading = true
    toggleLoadingIndicator()
    LunchKit.sharedInstance.getLunches(lunchDate, completion: {
      result in
      self.isLoading = false
      self.toggleLoadingIndicator()
      switch result {
      case .Success(_):
        self.lunches = LunchKit.sharedInstance.lunches
        self.saveLunches()
        self.currentIndex = 1
        if let viewController = self.lunchViewController(self.currentIndex ?? 0) {
          let viewControllers = [viewController]
          self.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
        }
      case .Failure(let error):
        switch(error) {
        case Errors.WrongNetworkFailure:
          self.showWrongNetworkError("You are not on the Kabbage network. Please join network and try again.")
        default:
          self.showAlert("Error loading lunches")
        }
      }
    })
  }
  
  func saveLunches() {
    let data = NSMutableData()
    let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
    archiver.encodeObject(lunches, forKey: "Lunches")
    archiver.finishEncoding()
    data.writeToFile(dataFilePath(), atomically: true)
  }
  
  func loadLunches() {
    isLoading = true
    toggleLoadingIndicator()
    let path = dataFilePath()
    
    // Check whether kabbageats.plist exists, and if so, grab and decode data
    if NSFileManager.defaultManager().fileExistsAtPath(path) {
      if let data = NSData(contentsOfFile: path) {
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        lunches = unarchiver.decodeObjectForKey("Lunches") as! [Lunch]
        LunchKit.sharedInstance.lunches = lunches
        unarchiver.finishDecoding()
        
        // Get today's date and check if menu for today is saved. If saved already, load from file
        let today = NSDate()
        let todayString = today.getStringFromDate()
        for lunch in lunches {
          if lunch.dateWithYear == todayString {
            if let startingIndex = lunches.indexOf(lunch) {
              if let viewController = lunchViewController(startingIndex) {
                let viewControllers = [viewController]
                self.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
              }
              isLoading = false
              toggleLoadingIndicator()
              return
            }
          }
        }
        // if no menu for today is stored in file, delete the file, then get new lunches. If menu for today is not in file, assumption is the data must be old since only consecutive data can be stored.
        do {
          try NSFileManager.defaultManager().removeItemAtPath(path)
          LunchKit.sharedInstance.lunches = [Lunch]()
          lunches = LunchKit.sharedInstance.lunches
          getLunches()
          return
        } catch {
          print("Unable to delete file")
          showAlert("Unable to load lunches")
        }
      }
    }
    // if file does not exist or bad data, get lunches
    getLunches()
  }
  
  func showAlert(message: String) {
    let alert = UIAlertController(title: "Whoops..", message: message, preferredStyle: .Alert)
    let OKaction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(OKaction)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func showWrongNetworkError(message: String) {
    let alert = UIAlertController(title: "Whoops..", message: message, preferredStyle: .Alert)
    let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
    let tryAgain = UIAlertAction(title: "Try Again", style: .Default, handler: {
      _ in
      self.getLunches()
    })
    // If no lunches have been loaded, try to load lunches. Otherwise, alert is only informational
    if LunchKit.sharedInstance.lunches.count > 0 {
      alert.addAction(ok)
    } else {
      alert.addAction(tryAgain)
    }
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func toggleLoadingIndicator() {
    if isLoading {
      parentController.indicatorView.hidden = false
      parentController.activityIndicator.startAnimating()
    } else {
      parentController.activityIndicator.stopAnimating()
      parentController.indicatorView.hidden = true
    }
  }
  
  // MARK: - Helper Methods
  func setStartDate() {
    // if Sunday, set start day at Friday
    if lunchDate.dayOfWeek() == 1 {
     lunchDate = lunchDate.updateByNumOfDays(-2)
      
      // if Monday, set start day at Friday
    } else if lunchDate.dayOfWeek() == 2 {
      lunchDate = lunchDate.updateByNumOfDays(-3)
      
      // Otherwise, set start day one day back
    } else {
      lunchDate = lunchDate.updateByNumOfDays(-1)
    }
  }
  
  // Sets a specific date for testing
  func setSpecificDate() -> NSDate {
    let comps = NSDateComponents()
    comps.day = 24
    comps.month = 5
    comps.year = 2016
    return NSCalendar.currentCalendar().dateFromComponents(comps)!
  }
  
  func documentsDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    return paths[0]
  }
  
  func dataFilePath() -> String {
    return (documentsDirectory() as NSString).stringByAppendingPathComponent("kabbageats.plist")
  }
  
}

// MARK: - Extensions
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
      // Check if at the end of the array, if so load next lunch
      if index == lunches.count {
        // Show activity indicator
        viewController.activityIndicator.startAnimating()
        viewController.indicatorView.hidden = false
        
        // Get next day in array
        let lastDayInArray = lunches[lunches.count - 1].dateWithYear
        if let date = lastDayInArray.getNextDateFromString() {
          
          lunchDate = date
          LunchKit.sharedInstance.getLunch(date, completion: {
            result in
            switch result {
            case .Success(_):
              self.lunches = LunchKit.sharedInstance.lunches
              self.saveLunches()
              if let viewController = self.lunchViewController(index - 1) {
                let viewControllers = [viewController]
                self.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
              }
            case .Failure(let error):
              switch error {
              case Errors.WrongNetworkFailure:
                self.showWrongNetworkError("Join Kabbage network to see future dates")
                viewController.activityIndicator.stopAnimating()
                viewController.indicatorView.hidden = true
              case Errors.NotFound:
                print("No lunch tomorrow \(date)")
                viewController.activityIndicator.stopAnimating()
                viewController.indicatorView.hidden = true
              default:
                print("Error loading next lunch: \(date)")
                viewController.activityIndicator.stopAnimating()
                viewController.indicatorView.hidden = true
              }
            }
          })
        } else {
          print("Unable to get next day after \(lastDayInArray)")
          viewController.activityIndicator.stopAnimating()
          viewController.indicatorView.hidden = true
        }
      } else {
        return lunchViewController(index)
      }
    }
    return nil
  }
}
