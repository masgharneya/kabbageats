//
//  LunchKit.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/28/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class LunchKit {
  
  static let sharedInstance = LunchKit()
  
  let baseURL = "https://lunch.kabbage.com/api/v2/lunches/"
  var lunches = [Lunch]()
  
  func requestWrapper(method: Alamofire.Method, url: String, params: [String:AnyObject]?, completion: (data: Response<AnyObject, NSError>) -> Void) {
    Manager.request(method, url, parameters: params).responseJSON {
      response in
      print(response)
      guard response.result.isSuccess else {
        self.showNetworkError()
        print("Error while retrieving lunch: \(response.result.error)")
        return
      }
      completion(data: response)
    }
  }
  
  func getLunch(date: NSDate, completion: ((date: NSDate) -> Void)?) {
    let lunchDate = date
    let dateStr = lunchDate.apiDateStringFromDate()
    // Make Get Request
    requestWrapper(.GET, url: "\(baseURL)\(dateStr)/", params: nil, completion: {
      data in
      // Parse JSON
      guard let lunchDict = data.result.value as? [String: AnyObject],
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
      lunch.getDishes()
      self.lunches.append(lunch)
      completion!(date: lunchDate)
    })
  }
  
  func getLunches(date: NSDate, completion: () -> Void) {
    getLunch(date, completion: { date in
      if self.lunches.count < 1 {
        print("Lunches: \(self.lunches.count)")
        let lunchDate = date.getNextWeekday()
        self.getLunch(lunchDate, completion: nil)
      } else {
        completion()
      }
    })
  }
  
  //TODO: Load lunch image
  /*
  func getImage(imageURL: String) {
    Manager.request(.GET, imageURL).response {
      result, response, data, error in
      if let data = data {
        lunch.image = UIImage(data: data)!
      }
    }
  }
 */
  
  
  func upVoteDish(dish: String, date: String, button: UIButton) {
    let params: [String : AnyObject] = [
      "dish": "\(dish)",
      "rating": 1,
      "source": "iOS App"
    ]
    
    requestWrapper(.POST, url: "\(baseURL)\(date)/ratings", params: params, completion: {
      data in
      guard data.response?.statusCode == 204 else { return }
        button.setImage(UIImage(named: "ThumbsUpHighlighted"), forState: .Normal)
    })
  }

  func showNetworkError() {
    let alert = UIAlertController(title: "Whoops...", message: "There was an error retrieving lunch.", preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(action)
    
    //presentViewController(alert, animated: true, completion: nil)
  }
}

// Server Trust Policy Manager for Alamofire (to accept self-signed certificate, from http://stackoverflow.com/questions/31945078/how-to-connect-to-self-signed-servers-using-alamofire-1-3 )
private var Manager: Alamofire.Manager = {
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