//
//  DetailViewController.swift
//  MovieDBDemo
//
//  Created by Jason Terhorst on 6/2/19.
//  Copyright © 2019 Jason Terhorst. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var dbCoordinator: MovieDBCoordinator? = nil

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.releaseDate!.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: Movie? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

