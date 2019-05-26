//
//  Spinner.swift
//  NewsApp
//
//  Created by Elshad on 5/24/19.
//  Copyright © 2019 Elshad. All rights reserved.
//

import UIKit

class Spinner {
    
    // Spinner shown during load the Collection View
    let spinner = UIActivityIndicatorView()
    let loadingView = UIView()
    
    // Add spinner to given view
    func addSpinner(view : UIView) {
        loadingView.frame = view.frame
        loadingView.backgroundColor = UIColor.white
        loadingView.alpha = 0.4
        view.addSubview(loadingView)
        view.addSubview(spinner)
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        spinner.transform = CGAffineTransform(scaleX: 2, y: 2)
        spinner.color = .black
        spinner.startAnimating()
    }
    
    // Remove spinner from the view
    func removeSpinner() {
        loadingView.isHidden = true
        spinner.stopAnimating()
    }
    
}
