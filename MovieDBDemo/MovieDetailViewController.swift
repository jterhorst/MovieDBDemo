//
//  DetailViewController.swift
//  MovieDBDemo
//
//  Created by Jason Terhorst on 6/2/19.
//  Copyright © 2019 Jason Terhorst. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var averageVotesLabel: UILabel!
    @IBOutlet weak var imdbDetailsButton: UIButton!
    
    @IBOutlet weak var boxArtImageView: JTCachingImageView!
    @IBOutlet weak var backgroundImageView: JTCachingImageView!
    
    var dbCoordinator: MovieDBCoordinator? = nil

    
    
    func configureView() {
        
        if let detail = detailItem {

            if let imageView = boxArtImageView {
                if let imageUrl = detail.posterPath {
                    
                    if let fullImageUrl = URL(string: "\(dbCoordinator!.imageBaseUrl!)\(dbCoordinator!.imagePosterSize!)\(imageUrl)") {
                        imageView.getImage(from: fullImageUrl)
                    }
                }
            }
            
            if let backgroundView = backgroundImageView {
                if let imageUrl = detail.backdropPath {
                    
                    if let fullImageUrl = URL(string: "\(dbCoordinator!.imageBaseUrl!)\(dbCoordinator!.imageBackdropSize!)\(imageUrl)") {
                        backgroundView.getImage(from: fullImageUrl)
                    }
                }
            }
            
            if let label = titleLabel {
                label.text = detail.originalTitle ?? detail.title ?? "No title"
            }
            if let label = taglineLabel {
                label.text = detail.tagline ?? ""
            }
            if let label = detailsLabel {
                label.text = detail.status ?? ""
            }
            if let label = averageVotesLabel {
                label.text = "\(detail.voteAverage)/10 avg"
                label.isHidden = detail.voteAverage == 0 || detail.voteCount == 0
            }
            if let imdbButton = imdbDetailsButton {
                if let imdb = detail.imdbID, imdb.count > 0 {
                    imdbButton.isHidden = false
                } else {
                    imdbButton.isHidden = true
                }
            }
            
            if let textView = overviewTextView {
                textView.text = detail.overview ?? "No details provided"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setToolbarHidden(true, animated: true)
        configureView()
    }
    
    var detailItem: Movie? {
        didSet {
            configureView()
            if let detail = detailItem {
                dbCoordinator?.loadDetailsForMovie(movie: detail) { dict in
                    detail.updateWithJson(payload: dict)
                    self.configureView()
                }
            }
        }
    }
    
    @objc func reloadContents() {
        configureView()
    }
    
    @IBAction func openImdb(sender: UIButton) {
        guard let detail = detailItem else { return }
        guard let imdbId = detail.imdbID else { return }
        guard let fullUrl = URL(string: "https://www.imdb.com/title/\(imdbId)") else { return }
        
        UIApplication.shared.open(fullUrl)
    }

}

