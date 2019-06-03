//
//  MovieDBCoordinator.swift
//  Movies!
//
//  Created by Jason Terhorst on 6/2/19.
//  Copyright © 2019 Jason Terhorst. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MovieDBCoordinator: NSObject {

    var managedObjectContext: NSManagedObjectContext? = nil
    var persistentContainer: NSPersistentContainer? = nil
    
    override init() {
        super.init()
    }
    
    private func loadResource(resourcePath: String) -> Data? {
        let incomingString = "https://api.themoviedb.org/3\(resourcePath)"
        print("string: \(incomingString)")
        if let fullURL = URL(string: incomingString) {
            print("url: \(fullURL)")
            do {
                let loadedData = try Data(contentsOf: fullURL)
                return loadedData
            } catch {
                print("failed to load data")
                return nil
            }
        }
        
        return nil
    }
    
    private func loadArray(resourcePath: String) -> [[String: Any]]? {
        if let data = self.loadResource(resourcePath: resourcePath) {
            print(String(data: data, encoding: String.Encoding.utf8))
            if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                if let jsonDict = json as? [String: Any] {
                    if let jsonArray = jsonDict["results"] as? [[String: Any]] {
                        return jsonArray
                    }
                }
                
            } else {
                print("failed to parse: \(data)")
            }
        }
        return nil
    }
    
    private func loadDict(resourcePath: String) -> [String: Any]? {
        if let data = self.loadResource(resourcePath: resourcePath) {
            if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                if let jsonDict = json as? [String: Any] {
                    return jsonDict
                }
            } else {
                print("failed to parse: \(data)")
            }
        }
        return nil
    }
    
    private func movieFromJSON(payload: [String: Any], context: NSManagedObjectContext) -> Movie {
        let matchFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        matchFetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["cloudID", payload["id"] as Any])
        let matchingMovies = try? context.fetch(matchFetchRequest)
        var movie = matchingMovies?.first as? Movie
        if movie == nil {
            movie = Movie(context: context)
        }
        movie?.updateWithJson(payload: payload)
        return movie!
    }
    
    public func nowPlayingMovies() {
        print("loading...")
        
        var apiKey = ""
        var plistDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "APIKeys", ofType:"plist") {
            plistDict = NSDictionary(contentsOfFile: path)
            apiKey = plistDict!["V3_API_KEY"] as! String
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.string(from: Date().addingTimeInterval(-2592000))
        let endDate = dateFormatter.string(from: Date())
        let apiPath = "/discover/movie?primary_release_date.gte=\(startDate)&primary_release_date.lte=\(endDate)&api_key=\(apiKey)"
        print("path: \(apiPath)")
        persistentContainer?.performBackgroundTask({ context in
            if let data = self.loadArray(resourcePath: apiPath) {
                for item in data {
                    print("parsing \(item)")
                    _ = self.movieFromJSON(payload: item, context: context)
                }
            }
            try? context.save()
        })
    }
    
    public func popularMovies() {
        
    }
    
    public func topRatedMovies() {
        
    }
    
    public func movieResults(matching search:String) -> [[String : Any]] {
        
        return []
    }
    
    
}
