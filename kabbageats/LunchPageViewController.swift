//
//  MenuPageViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/20/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit

class LunchPageViewController: UIPageViewController {
  var lunches: [Lunch]!
  var currentIndex: Int!
  var lunchDate = NSDate()
  var isLoading = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //setStartDate()
    lunchDate = setSpecificDate()
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
      lunch.lunchIndex = index
      if let img = lunches[index].image {
        lunch.image = img
      } 
      return lunch
    }
    return nil
  }
  
  func loadLunches() {
    // Make Get Request
    isLoading = true
    showLoading()
    LunchKit.sharedInstance.getLunches(lunchDate, completion: {
      result in
      self.isLoading = false
      self.showLoading()
      switch result {
      case .Success(let box):
        self.lunches = box.value
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
  
  func getNextLunch(index: Int) {
    // TODO: Update to use box
    // Make Get Request
    let lastDayInArray = lunches[lunches.count - 1].dateWithYear
    if let date = lastDayInArray.getDateFromString() {
      isLoading = true
      
      LunchKit.sharedInstance.getLunch(date, completion: {
        result in
        switch result {
        case .Success(_):
          self.isLoading = false
          self.lunches = LunchKit.sharedInstance.lunches
          if let viewController = self.lunchViewController(index - 1) {
            let viewControllers = [viewController]
            self.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
          }
        case .Failure(let error):
          switch error {
          case Errors.NotFound:
            self.showAlert("No lunch tomorrow")
            // TODO: Hide spinner
          default:
            self.showAlert("Error loading next lunch")
          }
        }
      })
    } else {
      showAlert("Unable to get next day")
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
  
  // Sets a specific date for testing when there is no future data
  func setSpecificDate() -> NSDate {
    let comps = NSDateComponents()
    comps.day = 24
    comps.month = 5
    comps.year = 2016
    return NSCalendar.currentCalendar().dateFromComponents(comps)!
  }
  
  func showAlert(message: String) {
    let alert = UIAlertController(title: "Whoops...", message: message, preferredStyle: .Alert)
    let OKaction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(OKaction)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func showWrongNetworkError(message: String) {
    let alert = UIAlertController(title: "Whoops...", message: message, preferredStyle: .Alert)
    let OKaction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    let tryAgain = UIAlertAction(title: "Try Again", style: .Default, handler: {
      _ in
      self.loadLunches()
    })
    alert.addAction(OKaction)
    alert.addAction(tryAgain)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func showLoading() {
    if let mainVC = self.parentViewController as? MainViewController {
      print("Loading: \(isLoading)")
      if isLoading {
        mainVC.indicatorView.hidden = false
        mainVC.activityIndicator.hidden = false
        mainVC.activityIndicator.startAnimating()
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
