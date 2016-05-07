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
  
  func requestWrapper2(method: Alamofire.Method, url: String, params: [String:AnyObject]?, completion: (Result<AnyObject>) -> Void) {
    Manager.request(method, url, parameters: params).responseJSON {
      response in
      print(response)
      if let result = response.result.value {
        completion(Result.Success(Box(value: result)))
      } else if let error = response.result.error {
        completion(Result.Failure(error))
        print("Error while retrieving lunch: \(error)")
        return
      }
    }
  }
  
  // MARK: Get Lunch Methods
  func getLunch(date: NSDate, completion: (date: NSDate) -> Void) {
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
      completion(date: lunchDate)
    })
  }
  
  func getLunch2(date: NSDate, completion: Result<NSDate> -> Void) {
    let lunchDate = date
    let dateStr = lunchDate.apiDateStringFromDate()
    // Make Get Request
    requestWrapper2(.GET, url: "\(baseURL)\(dateStr)/", params: nil) {
      result in
      switch result {
      case .Success(let box):
      guard
        let lunchDict = box.value as? [String: AnyObject],
        date = lunchDict["date"] as? String,
        menu = lunchDict["menu"] as? String,
        imageURL = lunchDict["image"] as? String else {
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
        completion(Result.Success(Box(value: lunchDate)))
      case .Failure(let error):
        completion(Result.Failure(error))
      }
    }
  }

  
  func getLunches(date: NSDate, completion: () -> Void) {
    getLunch(date, completion: { date in
      if self.lunches.count < 3 {
        let lunchDate = date.getNextWeekday()
        self.getLunches(lunchDate, completion: completion)
      } else {
        completion()
      }
    })
  }
  
  func getLunches2(date: NSDate, completion: Result<[Lunch]> -> Void) {
    getLunch2(date, completion: {
      result in
      switch result {
      case .Success(let box):
        if self.lunches.count < 3 {
          let lunchDate = box.value.getNextWeekday()
          self.getLunches2(lunchDate, completion: completion)
        } else {
          completion(Result.Success(Box(value: self.lunches)))
        }
      case .Failure(let error):
        completion(Result.Failure(error))
      }
    })
  }
  
  // Load lunch image
  func getImage(imageURL: String, completion: (data: NSData) -> Void) {
    Manager.request(.GET, imageURL).response {
      result, response, data, error in
      if let data = data {
        completion(data: data)
      }
      /*
       // Download Image
       if let url = NSURL(string: imageURL), data = NSData(contentsOfURL: url) {
       lunch.image = UIImage(data: data)!
       }
       */
    }
  }
  
  // MARK: Rate Lunch Methods
  func upVoteDish(dish: String, date: String, completion: () -> Void) {
    let params: [String : AnyObject] = [
      "dish": "\(dish)",
      "rating": 1,
      "source": "iOS App"
    ]
    
    requestWrapper(.POST, url: "\(baseURL)\(date)/ratings", params: params, completion: {
      data in
      guard data.response?.statusCode == 204 else {
        // TODO: show error if rate fails
        return }
        completion()
    })
  }
  
  func downVoteDish(dish: String, date: String, completion: () -> Void) {
    let params: [String : AnyObject] = [
      "dish": "\(dish)",
      "rating": -1,
      "source": "iOS App"
    ]
    
    requestWrapper(.POST, url: "\(baseURL)\(date)/ratings", params: params, completion: {
      data in
      guard data.response?.statusCode == 204 else {
        // TODO: show error if rate fails
        return }
      
        completion()
    })
  }
  
  // MARK: Comment on Lunch Methods
  func sendComment(message: String, name: String?, date: String, completion: () -> Void) {
    var params = ["message": message]
    if let name = name {
      params.updateValue(name, forKey: "name")
    }
    
    requestWrapper(.POST, url: "\(baseURL)\(date)/comments", params: params, completion: {
      data in
      guard data.response?.statusCode == 204 else { return }
        completion()
    })
  }

  // TODO: Fix show network error
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