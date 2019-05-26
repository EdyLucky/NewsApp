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
import SafariServices
import CoreData

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    let API_KEY = "cedf1927835348f7bd03d2f2126cb64c"
    let URL = "https://newsapi.org/v2/top-headlines"
    var params : [String:String] = [:]
    var allNews = [AllNews]()
    var allNewsCache = [AllNewsCache]()
    let spinner = Spinner()
    let hourCalculator = HourCalculator()
    var isWating : Bool = false
    var returnCount = 0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if there is internet connection

       // if Reachability.isConnectedToNetwork() {
            // launch spinner
            spinner.addSpinner(view: self.view)
            // Update URL with api_key, parameters and get data
            params = ["country" : "us", "pageSize" : "100", "apiKey" : API_KEY]
            getNewsData(url: URL, parameters: params)
            
       // } else {
            //print("no internet connection")
       // }
        
        
        //set delegate and datasource
        collectionView.delegate = self
        collectionView.dataSource = self
        //add space sides of collection view
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
    }
    
   
    //MARK: - Networking
    
    // getNewsData method
    
    func getNewsData(url: String, parameters: [String: String]) {
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
                response in
                if response.result.isSuccess {
                    print("Success! Got the news data")
                    let newsJSON : JSON = JSON(response.result.value!)
                    //print(newsJSON)
                    self.parseNewsData(json: newsJSON, count: 20)
                } else {
                    print("Error \(String(describing: response.result.error))")
                }
            }
        } else {
            
            // if no internet connection load from local
            loadNews()
            print("loaded")
            print(allNewsCache.count)
            for i in 0...allNewsCache.count - 1 {
                let title = allNewsCache[i].title
                let url = allNewsCache[i].url
                let time = allNewsCache[i].time
                let image = allNewsCache[i].imageLink
                let source = allNewsCache[i].url
                
                allNews.append(AllNews(pTitle: title!, pUrl: url!, pTime: time!, pImageLink: image!, pSource: source!))
            
            }
            print("Loaded data from core")
            returnCount = 21
            collectionView.reloadData()
            spinner.removeSpinner()
        }
        
    }
    
    
    //MARK: - JSON Parsing
    
    func parseNewsData(json : JSON, count : Int) {
        var totalCount = json["totalResults"].intValue
        if totalCount > 100 {
            totalCount = 100
        }
          deleteNews()
        for i in 0...totalCount-1 {
            let title = json["articles"][i]["title"].stringValue
            let url = json["articles"][i]["url"].stringValue
            let time = json["articles"][i]["publishedAt"].stringValue
            let image = json["articles"][i]["urlToImage"].stringValue
            let source = json["articles"][i]["source"]["name"].stringValue

            allNews.append(AllNews(pTitle: title, pUrl: url, pTime: time, pImageLink: image, pSource: source))
            
            // Save parsed data to Core data for loading when there is no internet connection
            
            let newallNewsCache = AllNewsCache(context: context)
            newallNewsCache.title = title
            newallNewsCache.url = url
            newallNewsCache.time = time
            newallNewsCache.imageLink = image
            newallNewsCache.source = source
            saveNews()
            
        }
        returnCount = 21
        collectionView.reloadData()
        spinner.removeSpinner()
    
    }
    
   
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // To expand collection view controller
    
     func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == returnCount - 1  && !isWating {
            isWating = true
            updateNextCell()
        }
    }

    func updateNextCell(){
        if returnCount <= allNews.count-1 {
            returnCount += 1//allNews.count - returnCount
            isWating = false
            DispatchQueue.main.async(execute: collectionView.reloadData)
        }

    }
    
    //MARK: - Save to SQLLite to reload when there is no internet connection
    
    func saveNews() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    
    // load news from core data
    func loadNews() {
        let request : NSFetchRequest<AllNewsCache> = AllNewsCache.fetchRequest()
        let predicate = NSPredicate(value: true)
        request.predicate = predicate
        do {
            allNewsCache = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    
    }
    
    // delete news from core data
    
    func deleteNews() {
        // create the delete request for the specified entity
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AllNewsCache.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        // perform the delete
        do {
            try persistentContainer.viewContext.execute(deleteRequest)
        } catch let error as NSError {
            print(error)
        }
    }
   
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return returnCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath as IndexPath) as! CustomCollectionViewCell
        let url = Foundation.URL(string:allNews[indexPath.item].imageLink)
        cell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "noimage.png"))
        cell.titleLabel.text = allNews[indexPath.item].title
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.sourceLabel.text = "From: \(allNews[indexPath.item].source)"
        cell.hourLabel.text = "\(String(hourCalculator.calculateDiffBetweenDatesinHours(date: allNews[indexPath.item].time))) hrs ago"
        if indexPath.item % 7 == 0 {
            cell.titleLabel.font = UIFont.systemFont(ofSize: 12)
            cell.sourceLabel.font = UIFont.systemFont(ofSize: 10)
        } else {
            cell.titleLabel.font = UIFont.systemFont(ofSize: 8)
            cell.sourceLabel.font = UIFont.systemFont(ofSize: 7)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let orientation = UIApplication.shared.statusBarOrientation
        
        if indexPath.item % 7 == 0 {
            let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right ))
            let itemHeight = self.view.frame.height / 2
            if orientation.isPortrait {
                return CGSize(width: itemSize, height: itemSize)
            } else {
                return CGSize(width: itemSize, height: itemHeight)
            }
            
        } else {
            let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
            
            let itemSize1 = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 30)) / 3
            
            if orientation.isPortrait {
                return CGSize(width: itemSize, height: itemSize)
            } else {
                return CGSize(width: itemSize1, height: itemSize1)
            }
            
            
        }
        
        
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // load safari services to view url
        let urlText = allNews[indexPath.item].url
        if let url = Foundation.URL(string: urlText) {
            let safariController = SFSafariViewController(url: url)
            present(safariController, animated: true , completion: nil)
        }
        
    }
    
}




