//
//  HourCalculator.swift
//  NewsApp
//
//  Created by Elshad on 5/24/19.
//  Copyright © 2019 Elshad. All rights reserved.
//

import UIKit

class HourCalculator {
    
    // Function converts string to date and finds different between given datetime and current datetime
    func calculateDiffBetweenDatesinHours(date : String) -> Int {
        let curDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: date) else {
            fatalError()
        }
        
        let cal = Calendar.current
        let components = cal.dateComponents([.hour], from: date, to: curDate)
        let diff = components.hour!
        return diff
    }
}
