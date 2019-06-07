//
//  MovieDBDemoTests.swift
//  MovieDBDemoTests
//
//  Created by Jason Terhorst on 6/2/19.
//  Copyright © 2019 Jason Terhorst. All rights reserved.
//

import XCTest
import CoreData

@testable import MovieDB

class MovieDBTests: XCTestCase {

    var model:NSManagedObjectModel? = nil
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func inMemoryStoreForTests() -> NSManagedObjectContext {
        if model == nil {
            model = NSManagedObjectModel.mergedModel(from: Bundle.allBundles)
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model!)
        try? psc.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil,  at: nil, options: nil)
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = psc
        
        return moc
    }
    
    func testJsonParsingPayloadIntoMovie() {
        
        let cloudId:Int64 = 1234567890
        let voteCount:Int64 = 100
        
        let exampleJson = ["poster_path":"/example_poster_path.jpg","imdb_id":"1234567890","adult":false,"overview":"This is a nifty test","release_date":"1970-1-1","genre_ids":[],"id":cloudId,"original_title":"The Original Test","original_language":"en","title":"Test","backdrop_path":"/example_backdrop.jpg","popularity":5.0,"vote_count":voteCount,"video":true,"vote_average":7.0] as [String : Any]
        
        let context = inMemoryStoreForTests()
        
        let movie = Movie(context: context)
        movie.updateWithJson(payload: exampleJson)
        
        XCTAssertEqual(movie.posterPath, "/example_poster_path.jpg")
        XCTAssertEqual(movie.imdbID, "1234567890")
        XCTAssertEqual(movie.adult, false)
        XCTAssertEqual(movie.overview, "This is a nifty test")
        XCTAssertEqual(movie.releaseDate, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(movie.cloudID, 1234567890)
        XCTAssertEqual(movie.originalTitle, "The Original Test")
        XCTAssertEqual(movie.originalLanguage, "en")
        XCTAssertEqual(movie.title, "Test")
        XCTAssertEqual(movie.backdropPath, "/example_backdrop.jpg")
        XCTAssertEqual(movie.popularity, 5.0)
        XCTAssertEqual(movie.voteCount, 100)
        XCTAssertEqual(movie.video, true)
        XCTAssertEqual(movie.voteAverage, 7)
        
    }

}
