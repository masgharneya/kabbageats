//
//  CommentViewController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/25/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit
import Alamofire

class CommentViewController: UIViewController {

  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var sendButton: UIButton!
  var date = ""
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    modalPresentationStyle = .Custom
    transitioningDelegate = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    popupView.layer.cornerRadius = 10
    
    textView.delegate = self
    nameField.delegate = self
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommentViewController.close))
    gestureRecognizer.cancelsTouchesInView = false
    gestureRecognizer.delegate = self
    view.addGestureRecognizer(gestureRecognizer)
    
    nameField.becomeFirstResponder()
  }
  
  // MARK: - Actions
  
  @IBAction func sendComment(sender: UIButton) {
    sendButton.enabled = false
    var params = [String : AnyObject]()
    if let message = textView.text {
      if let name = nameField.text {
        params = [
          "name": name,
          "message": message
        ]
      } else {
      params = [
        "message": message
        ]
      }
      Manager.request(.POST, "https://lunch.kabbage.com/api/v2/lunches/\(date)/comments", parameters: params).response {
        request, response, data, error in
        if response?.statusCode == 204 {
          print("Comment successful")
          self.nameField.resignFirstResponder()
          self.textView.resignFirstResponder()
          self.close()
        }
      }
    }
  }
  
  @IBAction func close() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

extension CommentViewController: UIViewControllerTransitioningDelegate {
  func presentationControllerForPresentedViewController(
    presented: UIViewController,
    presentingViewController presenting: UIViewController,
                             sourceViewController source: UIViewController)
    -> UIPresentationController? {
      
      return DimmingPresentationController(presentedViewController: presented,
                                           presentingViewController: presenting)
  }
}

extension CommentViewController: UIGestureRecognizerDelegate {
  // Close popup view if user taps outside of popup. Function returns true only if the user taps on the background and false if user taps inside the popup.
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    return (touch.view === self.view)
  }
}

extension CommentViewController: UITextFieldDelegate {
 
  // Limit name field to 30 characters
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    let currentCharacterCount = textField.text?.characters.count ?? 0
    if (range.length + range.location > currentCharacterCount){
      return false
    }
    
    let newLength = currentCharacterCount + string.characters.count - range.length
    return newLength <= 30
  }
}

extension CommentViewController: UITextViewDelegate {
  func textViewDidBeginEditing(textView: UITextView) {
    if textView.text == "Enter a comment (be nice!)" {
      textView.text = ""
      textView.textColor = UIColor.blackColor()
    }
  }
  
  // Enable send button if text view is not empty
  func textViewDidChange(textView: UITextView) {
    sendButton.enabled = textView.text != "" ? true : false
  }
  
  // Show placeholder text if text view is empty and disable Send button
  func textViewDidEndEditing(textView: UITextView) {
    if textView.text == "" {
      textView.text = "Enter a comment (be nice!)"
      textView.textColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.30)
      sendButton.enabled = false
    }
  }
  
  // Limit comments to 500 characters
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    let currentCharacterCount = textView.text?.characters.count ?? 0
    if (range.length + range.location > currentCharacterCount){
      return false
    }
    
    let newLength = currentCharacterCount + text.characters.count - range.length
    return newLength <= 500
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
