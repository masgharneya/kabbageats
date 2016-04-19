//
//  MenuViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/18/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit
import Alamofire

class MenuViewController: UIViewController {
  
  @IBOutlet weak var mainDishLabel: UILabel!
  @IBOutlet weak var sideDishLabel: UILabel!
  @IBOutlet weak var lunchImage: UIImageView!
  @IBOutlet weak var dateNavBarTitle: UINavigationItem!
  @IBOutlet weak var activityIndicatorView: UIView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  var downloadTask: NSURLSessionDownloadTask?
  var lunch = Lunch()
  var isLoading = false
  
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
    
    getLunch(lunch.date)
    self.dateNavBarTitle.title = self.lunch.todayString
  }
  
  @IBAction func refreshLunch(sender: UIBarButtonItem) {
    getLunch(lunch.date)
  }
  
  @IBAction func getTomorrowLunch(sender: UISwipeGestureRecognizer) {
    if sender.direction == .Left {
      print("swiped left")
      updateDate(1)
    } else if sender.direction == .Right {
      updateDate(-1)
    }
  }
  
  func getLunch(date: NSDate) {
    activityIndicatorView.hidden = false
    activityIndicator.startAnimating()
    let dateStr = lunch.jsonDateString
    Manager.request(.GET, "http://lunch.kabbage.com/api/v2/lunches/\(dateStr)/").validate().responseJSON {
      response in
      guard response.result.isSuccess else {
        print("Error while retrieving lunch: \(response.result.error)")
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
        self.activityIndicator.stopAnimating()
        self.activityIndicatorView.hidden = true
        self.mainDishLabel.text = self.lunch.mainDish
        self.sideDishLabel.text = self.lunch.sideDishes
        if let url = NSURL(string: self.lunch.imageURL) {
          self.downloadTask = self.lunchImage.loadImageWithURL(url)
        }
        self.dateNavBarTitle.title = self.lunch.todayString
      }
    }
  }
  
  func updateDate(nextDay: Int) {
    let oneDay = NSDateComponents()
    oneDay.day = nextDay
    guard let tomorrow = NSCalendar.currentCalendar().dateByAddingComponents(oneDay, toDate: lunch.date, options: .WrapComponents) else {
      print("Invalid date")
      return }
    
    lunch.date = tomorrow
    getLunch(lunch.date)
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

