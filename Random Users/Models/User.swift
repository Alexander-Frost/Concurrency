//
//  User.swift
//  Random Users
//
//  Created by Alex on 6/13/19.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import Foundation

struct User: Codable {
    let name: Name
    let picture: Picture
    let email: String
    let phone: String
}

struct Name: Codable {
    let title: String
    let first: String
    let last: String
}

struct Picture: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}

struct AllUsers: Codable {
    let results: [User]
}
