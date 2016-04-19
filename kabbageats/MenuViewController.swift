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
  
  var downloadTask: NSURLSessionDownloadTask?
  var lunch = Lunch()
  
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
    
    // TODO: Add shadow for Date Navigation Bar
    getLunch()
    
  }
  
  @IBAction func refreshLunch(sender: UIBarButtonItem) {
    getLunch()
  }
  
  func getLunch() {
    Manager.request(.GET, "http://lunch.kabbage.com/api/v2/lunches/2016-04-19/").validate().responseJSON {
      response in
      guard response.result.isSuccess else {
        print("Error while retrieving lunch: \(response.result.error)")
        return
      }
      
      guard let lunchDict = response.result.value as? [String: AnyObject],
        date = lunchDict["date"] as? String,
        menu = lunchDict["menu"] as? String,
        image = lunchDict["image"] as? String else {
          print("Received data not in the correct format")
          return
      }
      
      // Set lunch properties
      self.lunch.date = date
      self.lunch.fullMenu = menu
      self.lunch.imageURL = image
      print(self.lunch)
      self.lunch.getDishes()
      
      // Update UI
      dispatch_async(dispatch_get_main_queue()) {
        self.mainDishLabel.text = self.lunch.mainDish
        self.sideDishLabel.text = self.lunch.sideDishes
        if let url = NSURL(string: self.lunch.imageURL) {
          self.downloadTask = self.lunchImage.loadImageWithURL(url)
        }
      }
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

