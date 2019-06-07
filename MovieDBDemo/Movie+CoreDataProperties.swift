//
//  Movie+CoreDataProperties.swift
//  Movies!
//
//  Created by Jason Terhorst on 6/2/19.
//  Copyright © 2019 Jason Terhorst. All rights reserved.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var cloudID: Int64
    @NSManaged public var voteCount: Int64
    @NSManaged public var resultSortIndex: Int64
    @NSManaged public var video: Bool
    @NSManaged public var voteAverage: Double
    @NSManaged public var title: String?
    @NSManaged public var popularity: Double
    @NSManaged public var posterPath: String?
    @NSManaged public var originalLanguage: String?
    @NSManaged public var originalTitle: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var adult: Bool
    @NSManaged public var overview: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var imdbID: String?
    @NSManaged public var homepage: String?
    @NSManaged public var status: String?
    @NSManaged public var tagline: String?
    @NSManaged public var revenue: Int64
    @NSManaged public var budget: Int64
    @NSManaged public var runtime: Int64

}
