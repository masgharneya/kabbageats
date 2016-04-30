//
//  UIImageView+DownloadImage.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/17/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

// Allows user to call loadImageWithURL() on any UIImageView object

import UIKit

extension UIImageView {
  
  func loadImageWithURL(url: NSURL) {
    
  }
  
  func _loadImageWithURL(url: NSURL) -> NSURLSessionDownloadTask {
    let session = NSURLSession.sharedSession()
    let downloadTask = session.downloadTaskWithURL(url, completionHandler: {
      [weak self] url, response, error in // [weak self] used in case of UIImageView's removal before image arrives from server
        if error == nil, let url = url,
          data = NSData(contentsOfURL: url),
          image = UIImage(data: data) {
            // If image is successfully downloaded, set to UIImageView's image property on main thread
            dispatch_async(dispatch_get_main_queue()) {
              if let strongSelf = self { // verify UIImageView is still displayed
                strongSelf.image = image
              }
            }
        }
      })
    downloadTask.resume()
    return downloadTask // returning downloadTask gives caller opportunity to cancel() task
  }
}