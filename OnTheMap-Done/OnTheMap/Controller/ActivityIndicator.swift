//
//  ActivityIndicator.swift
//  OnTheMap
//
//  Created by Kyle Wilson on 2020-02-28.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation
import UIKit

struct ActivityIndicator {
    private static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    static func startActivityIndicator(view: UIView) {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    static func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
}
