//
//  UserDetailsViewController.swift
//  Random Users
//
//  Created by Alex on 6/14/19.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {

    // MARK: - Properties
    
    var myUser: User? {
        didSet {
            updateViews()
        }
    }
    var imageData: Data?
    let photoFetchQueue = OperationQueue()
    
    // MARK: - Outlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateViews()
    }
    
    // MARK: - Private
    
    private func updateViews() {
        
        guard let myUser = myUser, let url = URL(string: myUser.picture.large), isViewLoaded else {return}

        nameLbl.text = "Name: \(myUser.name.title). \(myUser.name.first) \(myUser.name.last)"
        emailLbl.text = "Email: \(myUser.email)"
        numberLbl.text = "Number: \(myUser.phone)"
        
        let fetchImageOp = FetchPhotoOperation(url: url) // 1.
        let fetchDataOp = BlockOperation { // 2.
            DispatchQueue.main.async {
                self.imageData = fetchImageOp.imageData
            }
        }
        let displayOp = BlockOperation { // 3.
            DispatchQueue.main.async {
                guard let imageData = self.imageData else { return }
                self.userImageView.image = UIImage(data: imageData)
            }
        }
        
        fetchDataOp.addDependency(fetchImageOp)
        displayOp.addDependency(fetchDataOp)
        
        photoFetchQueue.addOperations([fetchImageOp, fetchDataOp, displayOp], waitUntilFinished: false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
