//
//  Extensions.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 7/11/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil
        
        if let cacheImage = imageCache.object(forKey: urlString as NSString){
            self.image = cacheImage
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil{
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
                
            })
        }).resume()
    }
}
