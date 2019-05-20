//
//  HomeViewController.swift
//  NewsApp
//
//  Created by Elshad on 5/20/19.
//  Copyright © 2019 Elshad. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class HomeViewController: UIViewController {
    
    let API_KEY = "cedf1927835348f7bd03d2f2126cb64c"
    let URL = "https://newsapi.org/v2/top-headlines"
    var params : [String:String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Update URL with api_key
        params = ["country" : "us", "apiKey" : API_KEY]
        
        getNewsData(url: URL, parameters: params)
    }
    
    //MARK: - Networking
    
    // getNewsData method
    
    func getNewsData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the news data")
                let newsJSON : JSON = JSON(response.result.value!)
                print(newsJSON)
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    
    //MARK: - JSON Parsing
    
    
    
    //MARK: - Update UI
    
    
    


}

