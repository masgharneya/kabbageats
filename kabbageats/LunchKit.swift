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
  
  func GET(url: String, params: [String:AnyObject]?, completion: (Result<AnyObject>) -> Void) {
    Manager.request(.GET, url, parameters: params).validate().responseJSON {
      response in
      print(response)
      if let result = response.result.value {
        completion(Result.Success(Box(value: result)))
      } else if let error = response.result.error where error.code == -1004 {
          completion(Result.Failure(Errors.WrongNetworkFailure))
      } else if let code = response.response?.statusCode where code == 404 {
        completion(Result.Failure(Errors.NotFound))
      } else {
        completion(Result.Failure(Errors.NetworkFailure))
      }
      return
    }
  }
  
  func POST(url: String, params: [String:AnyObject]?, completion: (Result<AnyObject>) -> Void) {
    Manager.request(.POST, url, parameters: params).responseJSON {
      response in
      print(response)
      if response.result.isSuccess {
        guard let statusCode = response.response?.statusCode else { return }
        if statusCode == 204 {
          completion(Result.Success(Box(value: true)))
        } else {
          completion(Result.Failure(Errors.PostFailure))
        }
      } else if let error = response.result.error {
        completion(Result.Failure(Errors.NetworkFailure))
        print("Error during POST: \(error)")
        return
      }
    }
  }
  
  func getLunch(date: NSDate, completion: Result<NSDate> -> Void) {
    let lunchDate = date
    let dateStr = lunchDate.apiDateStringFromDate()
    // Make Get Request
    GET("\(baseURL)\(dateStr)/", params: nil) {
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
        let lunch = Lunch()
        lunch.dateWithYear = date
        lunch.date = date.getTodayString()
        lunch.fullMenu = menu
        lunch.imageURL = imageURL
        self.lunches.append(lunch)
        completion(Result.Success(Box(value: lunchDate)))
      case .Failure(let error):
        completion(Result.Failure(error))
      }
    }
  }
  
  func getLunches(date: NSDate, completion: Result<[Lunch]> -> Void) {
    getLunch(date, completion: {
      result in
      switch result {
      case .Success(let box):
        if self.lunches.count < 3 {
          let lunchDate = box.value.getNextWeekday()
          self.getLunches(lunchDate, completion: completion)
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
  
  func postDishRating(dish: String, date: String, rating: Int, completion: (Result<Bool>) -> Void) {
    let params: [String : AnyObject] = [
      "dish": "\(dish)",
      "rating": rating,
      "source": "iOS App"
    ]
    
    POST("\(baseURL)\(date)/ratings", params: params, completion: {
      result in
      switch result {
      case .Success(_):
        completion(Result.Success(Box(value: true)))
      case .Failure(let error):
        completion(Result.Failure(Errors.RatingFailure))
        print("Error rating dish: \(error)")
      }
    })
  }
  
  // MARK: Comment on Lunch Methods
  func sendComment(message: String, name: String?, date: String, completion: (Result<Bool>) -> Void) {
    var params = ["message": message]
    if let name = name {
      params.updateValue(name, forKey: "name")
    }
    
    POST("\(baseURL)\(date)/comments", params: params, completion: {
      result in
      switch result {
      case .Success(_):
        completion(Result.Success(Box(value: true)))
      case .Failure(let error):
          completion(Result.Failure(Errors.CommentFailure))
          print("Error sending comment: \(error)")
      }
    })
  }
}

enum Errors: ErrorType {
  
  case WrongNetworkFailure
  case NetworkFailure
  case NotFound
  case PostFailure
  case RatingFailure
  case CommentFailure
  case BadData
  case Unknown
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