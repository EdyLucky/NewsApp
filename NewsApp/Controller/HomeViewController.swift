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
import SDWebImage

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let API_KEY = "cedf1927835348f7bd03d2f2126cb64c"
    let URL = "https://newsapi.org/v2/top-headlines"
    var params : [String:String] = [:]
    var allNews = [AllNews]()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourLabel.adjustsFontSizeToFitWidth = true
        titleLabel.adjustsFontSizeToFitWidth = true
        contentLabel.adjustsFontSizeToFitWidth = true
        sourceLabel.adjustsFontSizeToFitWidth = true
        
        // Update URL with api_key
        params = ["country" : "us", "apiKey" : API_KEY]
        getNewsData(url: URL, parameters: params)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
   
    //MARK: - Networking
    
    // getNewsData method
    
    func getNewsData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the news data")
                let newsJSON : JSON = JSON(response.result.value!)
                //print(newsJSON)
                self.parseNewsData(json: newsJSON, count: 5)
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    
    //MARK: - JSON Parsing
    
    func parseNewsData(json : JSON, count : Int) {
        
        for i in 0...count {
            let title = json["articles"][i]["title"].stringValue
            let content = json["articles"][i]["content"].stringValue
            let time = json["articles"][i]["publishedAt"].stringValue
            let image = json["articles"][i]["urlToImage"].stringValue
            let source = json["articles"][i]["source"]["name"].stringValue
            
            allNews.append(AllNews(pTitle: title, pContent: content, pTime: time, pImageLink: image, pSource: source))

            //print(time)
        }
        updateUI(index: 0)
        
    
    }
    
    
    //MARK: - Update UI
    
    func updateUI(index : Int) {
        titleLabel.text = allNews[index].title
        contentLabel.text = allNews[index].content
        sourceLabel.text = allNews[index].source
        imageView.contentMode = .scaleAspectFit
        let url = Foundation.URL(string:allNews[index].imageLink)
        imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "brain.png"))
        let hour = calculateDiffBetweenDatesinHours(date: allNews[index].time)
        hourLabel.text = "\(hour) hrs ago"
        collectionView.reloadData()
        
    }
    
    // Function converts string to date and finds different between given datetime and current datetime
    func calculateDiffBetweenDatesinHours(date : String) -> Int {
        let curDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        //according to date format your date string
        guard let date = dateFormatter.date(from: date) else {
            fatalError()
        }
        print(date)
        print(curDate)
        
        let cal = Calendar.current
        let components = cal.dateComponents([.hour], from: date, to: curDate)
        let diff = components.hour!
        print(diff)
        
        return diff
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    


}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allNews.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath as IndexPath) as! CustomCollectionViewCell
        let url = Foundation.URL(string:allNews[indexPath.item].imageLink)
        cell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "brain.png"))
        cell.titleLabel.text = allNews[indexPath.item].title
        print(cell.titleLabel.text)
        //print("indexxxrow \(indexPath.row)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //print("indexxx \(indexPath.item)")
        
        if indexPath.item == 0 {
            let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10))
            return CGSize(width: itemSize, height: itemSize)
        } else {
            let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
            
            let itemSize1 = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 20)) / 3
            
            let orientation = UIApplication.shared.statusBarOrientation
            
            if orientation.isPortrait {
                // print("Portrait")
                return CGSize(width: itemSize, height: itemSize)
            } else {
                //print("Landscape")
                return CGSize(width: itemSize1, height: itemSize1)
            }
        }
        
        
        
    }
    
}




