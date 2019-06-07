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
    
    public static let MovieDBCoordinatorConfigUpdated: NSNotification.Name = NSNotification.Name(rawValue: "MovieDBCoordinatorConfigUpdated")

    var managedObjectContext: NSManagedObjectContext? = nil
    var persistentContainer: NSPersistentContainer? = nil
    
    
    
    var imageBaseUrl: String? = nil
    var imageBackdropSize: String? = nil
    var imagePosterSize: String? = nil
    
    override init() {
        super.init()
    }
    
    public func loadImageConfiguration() {
        var apiKey = ""
        var plistDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "APIKeys", ofType:"plist") {
            plistDict = NSDictionary(contentsOfFile: path)
            apiKey = plistDict!["V3_API_KEY"] as! String
        }
        
        let apiPath = "/configuration?api_key=\(apiKey)"
        if let configUrl = URL(string: "https://api.themoviedb.org/3\(apiPath)") {
            URLSession.shared.dataTask(with: configUrl, completionHandler: { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                    if let imagesConfig = json!["images"] as? [String:Any] {
                        if let newBaseUrl = imagesConfig["secure_base_url"] as? String {
                            self.imageBaseUrl = newBaseUrl
                        }
                        if let backdropSizes = imagesConfig["backdrop_sizes"] as? [String] {
                            self.imageBackdropSize = backdropSizes[backdropSizes.count - 2]
                        }
                        if let posterSizes = imagesConfig["poster_sizes"] as? [String] {
                            self.imagePosterSize = posterSizes[posterSizes.count - 2]
                        }
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: MovieDBCoordinator.MovieDBCoordinatorConfigUpdated, object: nil)
                        }
                    }
                }
            }).resume()
        }
    }
    
    private func loadResource(resourcePath: String) -> Data? {
        let incomingString = "https://api.themoviedb.org/3\(resourcePath)"
        
        if let fullURL = URL(string: incomingString) {
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
        assert(movie != nil)
        return movie!
    }
    
    public func nowPlayingMovies() {
        
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
        
        persistentContainer?.performBackgroundTask({ context in
            if let data = self.loadArray(resourcePath: apiPath) {
                for item in data {
                    print("parsing \(item)")
                    _ = self.movieFromJSON(payload: item, context: context)
                }
            }
            try? context.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: MovieDBCoordinator.MovieDBCoordinatorConfigUpdated, object: nil)
            }
        })
    }
    
    public func popularMovies() {
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
        let apiPath = "/discover/movie?sort_by=popularity.desc&primary_release_date.gte=\(startDate)&primary_release_date.lte=\(endDate)&api_key=\(apiKey)"
        
        persistentContainer?.performBackgroundTask({ context in
            if let data = self.loadArray(resourcePath: apiPath) {
                for item in data {
                    _ = self.movieFromJSON(payload: item, context: context)
                }
            }
            try? context.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: MovieDBCoordinator.MovieDBCoordinatorConfigUpdated, object: nil)
            }
        })
    }
    
    public func topRatedMovies() {
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
        let apiPath = "/discover/movie?sort_by=vote_average.desc&primary_release_date.gte=\(startDate)&primary_release_date.lte=\(endDate)&api_key=\(apiKey)"
        print("path: \(apiPath)")
        persistentContainer?.performBackgroundTask({ context in
            if let data = self.loadArray(resourcePath: apiPath) {
                for item in data {
                    print("parsing \(item)")
                    _ = self.movieFromJSON(payload: item, context: context)
                }
            }
            try? context.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: MovieDBCoordinator.MovieDBCoordinatorConfigUpdated, object: nil)
            }
        })
    }
    
    public func movieResults(matching search:String, completion: @escaping (_ result: [Movie]) -> Void) {
        var apiKey = ""
        var plistDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "APIKeys", ofType:"plist") {
            plistDict = NSDictionary(contentsOfFile: path)
            apiKey = plistDict!["V3_API_KEY"] as! String
        }
        
        if let encodedSearchQuery = search.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            let apiPath = "/search/movie?query=\(encodedSearchQuery)&api_key=\(apiKey)&include_adult=false"
            print("path: \(apiPath)")
            persistentContainer?.performBackgroundTask({ context in
                var backgroundMovies: [Movie] = []
                
                if let data = self.loadArray(resourcePath: apiPath) {
                    for item in data {
                        print("parsing \(item)")
                        backgroundMovies.append(self.movieFromJSON(payload: item, context: context))
                    }
                }
                try? context.save()
                
                var movieObjectIDs: [NSManagedObjectID] = []
                for movieObj in backgroundMovies {
                    movieObjectIDs.append(movieObj.objectID)
                }
                
                DispatchQueue.main.async {
                    let moc = self.persistentContainer?.viewContext
                    var movies:[Movie] = []
                    
                    for movieID in movieObjectIDs {
                        if let movieObj = try? moc?.existingObject(with: movieID) as! Movie {
                            movies.append(movieObj)
                        }
                    }
                    
                    completion(movies)
                }
            })
        } else {
            completion([]);
        }
        
    }
    
    
//    public func getImage(from url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
//        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) {
//            completion(imageFromCache)
//            return
//        }
//
//        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
//            guard let data = data, error == nil else {
//                DispatchQueue.main.async {
//                    completion(nil)
//                }
//                return;
//            }
//
//            DispatchQueue.main.async {
//                if let image = UIImage(data: data) {
//                    imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
//                    completion(image)
//                }
//
//            }
//        }).resume()
//    }
    
}
