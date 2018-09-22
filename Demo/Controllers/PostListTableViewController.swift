//
//  PostListTableViewController.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 08/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import UIKit
import CoreData

class PostListTableViewController: FetchedResultsTableViewController, UISplitViewControllerDelegate {
    
    var client = PostsClient()
    var dataSource = PostListDataSource()
    var storageManager = PostStorageManager() 
    
    var fetchedResultsController: NSFetchedResultsController<CDPost>?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.fetchedResultsController = fetchedResultsController
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.separatorInset = .zero
        navigationItem.title = "Post List"
    
        client.fetch { (result) in
            switch result {
            case.success(let fetchedPosts): self.storageManager.insert(fetchedPosts) { error in
                self.displayErrorNotification(description: "Database Update Error", error: error)
            }
            case.failure(let error):
                self.displayErrorNotification(description: "Network Fetch Error", error: error)
            }
            self.updateUI()
        }
    }
    
    private func updateUI()  {
        fetchedResultsController = storageManager.createFetchedResultsController()
        fetchedResultsController?.delegate = self
        dataSource.fetchedResultsController = fetchedResultsController
        
        do { try fetchedResultsController?.performFetch()
            tableView.reloadData()
        } catch {
            displayErrorNotification(description: "Database Fetch Error", error: CoreDataError.fetchRequestFailed)
        }
    }
    
    //MARK: - Error Handling
    private func displayErrorNotification(description: String, error: Error?) {
        let details = description + " " + ((error?.localizedDescription) ?? "")
        print(details)
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - SplitViewControllerDelegate
    private var collapseDetailViewController = true
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
    
    //MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       performSegue(withIdentifier: Segues.detailSegue, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.detailSegue {
            if let postDetailVC = segue.destination.contents as? PostDetailViewController {
                if let indexPath = sender as? IndexPath {
                    postDetailVC.post = fetchedResultsController?.object(at: indexPath).asPost()
                    collapseDetailViewController = false
                }
            }
        }
    }
}


