//
//  ImageService.swift
//  Movy
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation
import UIKit

class ImageService{
    
    static let sharedInstance = ImageService()
    let imageCache:NSCache = NSCache<NSString,UIImage>()
    let IMAGE_DOWNLOAD_BASE_URL = "https://image.tmdb.org/t/p/original"
    
    internal func downloadImage(path:String, forCell indexPath:IndexPath, completionHandler:@escaping (UIImage?) -> Void){
        
        DispatchQueue.global(qos: .background).async {
            var downloadedImage = self.checkCache(path: path)
            if downloadedImage != nil{
                completionHandler(downloadedImage)
            }else{
                let url = URL(string: self.IMAGE_DOWNLOAD_BASE_URL+path)
                
                let task = URLSession.shared.dataTask(with: url!) {[weak self] (responseData, responseUrl, error) -> Void in
                    if let data = responseData{
                        downloadedImage = UIImage(data: data)
                        if downloadedImage != nil{
                            self?.imageCache.setObject(downloadedImage!, forKey: path as NSString)
                            completionHandler(UIImage(data: data))
                        }
                    }
                }
                
                task.resume()
            }
        }
    }
    
    fileprivate func checkCache(path:String) -> UIImage?{
        return self.imageCache.object(forKey: path as NSString)
    }
}
