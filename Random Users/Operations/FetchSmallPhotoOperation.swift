//
//  FetchSmallPhotoOperation.swift
//  Random Users
//
//  Created by Alex on 6/14/19.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import Foundation

class FetchSmallPhotoOperation: ConcurrentOperation {
    
    // MARK: - Properties

    var thumbnailURL: URL?
    var thumbnailData: Data?
    
    // MARK: - VC Lifecycle
    
    init(url: URL) {
        self.thumbnailURL = url
    }
    
    override func start() {
//        super.start()
        if isCancelled {
            state = .isFinished
            return
        }
        state = .isExecuting
        main()
    }
    
    override func cancel() {
//        super.cancel()
        state = .isFinished
    }
    
    override func main() {
//        super.main()
        guard let url = thumbnailURL else {
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
            self.thumbnailData = data
            self.state = .isFinished
            }.resume()
    }
}
