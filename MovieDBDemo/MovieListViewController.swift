//
//  MasterViewController.swift
//  MovieDBDemo
//
//  Created by Jason Terhorst on 6/2/19.
//  Copyright © 2019 Jason Terhorst. All rights reserved.
//

import UIKit
import CoreData

class MovieListTableViewCell : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var posterImageView: JTCachingImageView!
    
}

class MovieListViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {

    var detailViewController: MovieDetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var dbCoordinator: MovieDBCoordinator? = nil
    
    let searchField = UISearchBar(frame: .zero)
    let listTypeSegmentedControl = UISegmentedControl(items: ["Now Playing","Popular","Top Rated"])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isToolbarHidden = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        searchField.placeholder = "Search movies"
        searchField.delegate = self
        searchField.tintColor = .black
        navigationItem.titleView = searchField
        
        setToolbarItems([UIBarButtonItem(customView: listTypeSegmentedControl)], animated: false)
        listTypeSegmentedControl.selectedSegmentIndex = 0
        listTypeSegmentedControl.addTarget(self, action: #selector(updateForSegmentedControlChange), for: .valueChanged)
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? MovieDetailViewController
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadContents), name: MovieDBCoordinator.MovieDBCoordinatorConfigUpdated, object: nil)
        
        _refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        navigationController?.setToolbarHidden(false, animated: true)
        
        super.viewWillAppear(animated)
    }
    
    @objc private func refreshData(_ sender: Any) {
        _refreshData()
    }
    
    @objc func reloadContents() {
        _fetchedResultsController = nil
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func _refreshData() {
        switch listTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            dbCoordinator?.nowPlayingMovies()
            break
        case 1:
            dbCoordinator?.popularMovies()
            break
        case 2:
            dbCoordinator?.topRatedMovies()
            break
        default:
            dbCoordinator?.nowPlayingMovies()
            break
        }
        
        _fetchedResultsController = nil
        tableView.reloadData()
    }
    
    @objc func updateForSegmentedControlChange(sender: UISegmentedControl) {
        _refreshData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            dbCoordinator?.movieResults(matching: searchText)
        }
        
        _fetchedResultsController = nil
        tableView.reloadData()
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchField.resignFirstResponder()
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! MovieDetailViewController
                controller.dbCoordinator = self.dbCoordinator
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - scrolling behavior
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchField.resignFirstResponder()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchField.resignFirstResponder()
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? MovieListTableViewCell
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell!, withEvent: event)
        return cell!
    }

    func configureCell(_ cell: MovieListTableViewCell, withEvent event: Movie) {
        cell.titleLabel!.text = event.title ?? event.originalTitle ?? "No title"
        var convertedReleaseDate:String? = nil
        if event.tagline == nil, let date = event.releaseDate {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none
            convertedReleaseDate = "Released \(df.string(from: date))"
        }
        cell.subtitleLabel!.text = event.tagline ?? convertedReleaseDate ?? event.overview ?? ""
        
        if let imageView = cell.posterImageView {
            if let imageUrl = event.posterPath {
                if let baseurl = dbCoordinator!.imageBaseUrl, let posterSize = dbCoordinator!.imagePosterSize {
                    if let fullImageUrl = URL(string: "\(baseurl)\(posterSize)\(imageUrl)") {
                        imageView.getImage(from: fullImageUrl)
                    }
                }
                
            }
        }
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Movie> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        if let searchText = searchField.text, searchText.count > 0 {
            let filterPredicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", argumentArray: ["title",searchText,"originalTitle",searchText])
            fetchRequest.predicate = filterPredicate
            let sortDescriptor = NSSortDescriptor(key: "resultSortIndex", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
        } else {
            switch listTypeSegmentedControl.selectedSegmentIndex {
            case 0: // now playing
                do {
                    let startDate = Date().addingTimeInterval(-2592000)
                    let endDate = Date()
                    let filterPredicate = NSPredicate(format: "%K >= %@ && %K <= %@", argumentArray: ["releaseDate",startDate,"releaseDate",endDate])
                    fetchRequest.predicate = filterPredicate
                    let sortDescriptor = NSSortDescriptor(key: "releaseDate", ascending: false)
                    fetchRequest.sortDescriptors = [sortDescriptor]
                }
            case 1: // popular
                do {
                    let startDate = Date().addingTimeInterval(-2592000)
                    let endDate = Date()
                    let filterPredicate = NSPredicate(format: "%K >= %@ && %K <= %@", argumentArray: ["releaseDate",startDate,"releaseDate",endDate])
                    fetchRequest.predicate = filterPredicate
                    let sortDescriptor = NSSortDescriptor(key: "popularity", ascending: false)
                    fetchRequest.sortDescriptors = [sortDescriptor]
                }
            case 2: // top rated
                do {
                    let startDate = Date().addingTimeInterval(-2592000)
                    let endDate = Date()
                    let filterPredicate = NSPredicate(format: "%K >= %@ && %K <= %@", argumentArray: ["releaseDate",startDate,"releaseDate",endDate])
                    fetchRequest.predicate = filterPredicate
                    let sortDescriptor = NSSortDescriptor(key: "voteAverage", ascending: false)
                    fetchRequest.sortDescriptors = [sortDescriptor]
                }
            default:
                do {
                    let sortDescriptor = NSSortDescriptor(key: "releaseDate", ascending: false)
                    fetchRequest.sortDescriptors = [sortDescriptor]
                }
            }
        }
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Movie>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!) as! MovieListTableViewCell, withEvent: anObject as! Movie)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!) as! MovieListTableViewCell, withEvent: anObject as! Movie)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}

