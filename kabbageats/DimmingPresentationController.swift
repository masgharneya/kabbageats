//
//  DimmingPresentationController.swift
//  kabbageats
//
//  Created by Marisa Toodle on 4/24/16.
//  Copyright © 2016 marisalaneous. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
  override func shouldRemovePresentersView() -> Bool {
    return false
  }
}