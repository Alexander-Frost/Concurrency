//
//  UserController.swift
//  Random Users
//
//  Created by Alex on 6/14/19.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import Foundation

class UserController: ConcurrentOperation {
    
    // MARK: - Properties
    
    var allUsers: AllUsers?
    private let baseUrl = URL(string: "https://randomuser.me/api/?format=json&inc=name,email,phone,picture&results=1000")!
    
    // MARK: - VC Lifecycle
    
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
        URLSession.shared.dataTask(with: baseUrl) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching image: \(error.localizedDescription)")
                self.state = .isFinished
                return
            }
            guard let data = data else {
                self.state = .isFinished
                return
            }
            do {
                let allUsers = try JSONDecoder().decode(AllUsers.self, from: data)
                self.allUsers = allUsers
            } catch {
                NSLog("Error fetching users: \(error.localizedDescription)")
            }
            self.state = .isFinished
            }.resume()
    }
}
