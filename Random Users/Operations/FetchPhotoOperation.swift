//
//  FetchPhotoOperation.swift
//  Random Users
//
//  Created by Alex on 6/14/19.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    // MARK: - Properties
    
    var imageURL: URL?
    var imageData: Data?
    
    // MARK: - VC Lifecycle
    
    init(url: URL) {
        self.imageURL = url
    }
    
    override func start() {
        if isCancelled {
            state = .isFinished
            return
        }
        state = .isExecuting
        main()
    }
    
    override func cancel() {
        state = .isFinished
    }
    
    override func main() {
        guard let url = imageURL else {
            self.state = .isFinished
            return
        }
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching image: \(error)")
                self.state = .isFinished
                return
            }
            guard let data = data else {
                self.state = .isFinished
                return
            }
            self.imageData = data
            self.state = .isFinished
            }.resume()
    }
    
}
