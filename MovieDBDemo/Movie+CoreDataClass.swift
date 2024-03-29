//
//  Movie+CoreDataClass.swift
//  Movies!
//
//  Created by Jason Terhorst on 6/2/19.
//  Copyright © 2019 Jason Terhorst. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Movie)
public class Movie: NSManagedObject {

    public func updateWithJson(payload: [String:Any]) {
        if let adult = payload["adult"] {
            self.adult = adult as! Bool
        }
        
        if let path = payload["backdrop_path"] {
            self.backdropPath = path as? String
        }
        
        if let budget = payload["budget"] {
            self.budget = budget as! Int64
        }
        
        if let homepage = payload["homepage"] {
            self.homepage = homepage as? String
        }
        
        if let remoteId = payload["id"] {
            self.cloudID = remoteId as! Int64
        }
        
        if let imdbId = payload["imdb_id"] {
            self.imdbID = imdbId as? String
        }
        
        if let lang = payload["original_language"] {
            self.originalLanguage = lang as? String
        }
        
        if let title = payload["original_title"] {
            self.originalTitle = title as? String
        }
        
        if let title = payload["title"] {
            self.title = title as? String
        }
        
        if let overview = payload["overview"] {
            self.overview = overview as? String
        }
        
        if let pop = payload["popularity"] {
            self.popularity = pop as! Double
        }
        
        if let path = payload["poster_path"] {
            self.posterPath = path as? String
        }
        
        if let dateString = payload["release_date"] {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.releaseDate = dateFormatter.date(from: dateString as! String)
        }
        
        if let revenue = payload["revenue"] {
            self.revenue = revenue as! Int64
        }
        
        if let voteAvg = payload["vote_average"] {
            self.voteAverage = voteAvg as! Double
        }
        
        if let voteCount = payload["vote_count"] {
            self.voteCount = voteCount as! Int64
        }
        
        if let video = payload["video"] {
            self.video = video as! Bool
        }
        
    }
    
}
