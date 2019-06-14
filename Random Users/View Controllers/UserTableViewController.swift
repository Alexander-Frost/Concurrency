//
//  UserTableViewController.swift
//  Random Users
//
//  Created by Alex on 6/14/19.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var allUsers: AllUsers?
    var cache = Cache<String, Data>()
    var fetchDictionary = [String : FetchSmallPhotoOperation]()
    let userFetchQueue = OperationQueue()
    let photoFetchQueue = OperationQueue()
    let userController = UserController()
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loadUsersOp = BlockOperation {
            DispatchQueue.main.async {
                self.allUsers = self.userController.allUsers
            }
        }
        let refreshTVOp = BlockOperation {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        loadUsersOp.addDependency(userController)
        refreshTVOp.addDependency(loadUsersOp)
        
        userFetchQueue.addOperations([userController, loadUsersOp, refreshTVOp], waitUntilFinished: false)
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allUsers?.results.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        
        guard let myUser = allUsers?.results[indexPath.row] else { return UITableViewCell()}
        cell.userNameLbl.text = "\(myUser.name.title). \(myUser.name.first) \(myUser.name.last)"
        loadImage(forCell: cell, forItemAt: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let myUser = allUsers?.results[indexPath.row] else {return}
        
        let userName = "\(myUser.name.title) \(myUser.name.first) \(myUser.name.last)"
        if let operation = fetchDictionary[userName] {
            operation.cancel()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "User Detail Segue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let destinationVC = segue.destination as? UserDetailsViewController {
                    destinationVC.myUser = allUsers?.results[indexPath.row]
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func loadImage(forCell cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        let lock = NSLock()
        var imageData: Data?
        
        guard let myUser = allUsers?.results[indexPath.row],
            let thumbnaillUrl = URL(string: (myUser.picture.thumbnail))
            else {return}
        
        let userName = "\(myUser.name.title) \(myUser.name.first) \(myUser.name.last)"

        if let cachedImageData = cache.value(for: userName),
            let image = UIImage(data: cachedImageData) {
            cell.imageView!.image = image
        } else {
            let fetchOp = FetchSmallPhotoOperation(url: thumbnaillUrl)
            let getDataOp = BlockOperation {
                lock.lock()
                imageData = fetchOp.thumbnailData
                lock.unlock()
            }
            let cacheOp = BlockOperation {
                lock.lock()
                if let data = imageData {
                    self.cache.cache(value: data, for: userName)
                }
                lock.unlock()
            }
            let displayOp = BlockOperation {
                lock.lock()
                if fetchOp.thumbnailURL?.absoluteString == myUser.picture.thumbnail {
                    DispatchQueue.main.async {
                        guard let data = imageData else {return}
                        cell.imageView!.image = UIImage(data: data)
                    }
                }
                lock.unlock()
            }
            
            getDataOp.addDependency(fetchOp)
            cacheOp.addDependency(getDataOp)
            displayOp.addDependency(getDataOp)
            fetchDictionary[userName] = fetchOp
            
            photoFetchQueue.maxConcurrentOperationCount = 1
            photoFetchQueue.addOperations([fetchOp, getDataOp, cacheOp, displayOp], waitUntilFinished: false)
        }
    }

}
