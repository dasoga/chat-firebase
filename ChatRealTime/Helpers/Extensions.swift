//
//  Extensions.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 7/11/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit

let imageCache = NSCache()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        if let cacheImage = imageCache.objectForKey(urlString) as? UIImage{
            self.image = cacheImage
            return
        }
        
        let url = NSURL(string: urlString)
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
            
            if error != nil{
                print(error)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    self.image = downloadedImage
                }
                
            })
        }).resume()
    }
}
