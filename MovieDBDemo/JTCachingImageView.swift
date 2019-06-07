//
//  JTCachingImageView.swift
//  Movies
//
//  Created by Jason Terhorst on 6/6/19.
//  Copyright © 2019 Jason Terhorst. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, UIImage>()

class JTCachingImageView: UIImageView {

    public func getImage(from url: URL) {
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.image = nil
                }
                return;
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
                    self.image = image
                }
                
            }
        }).resume()
    }

}
