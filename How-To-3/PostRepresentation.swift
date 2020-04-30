//
//  Post+Codable.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/27/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation

class PostRepresentation: Codable {

    var id: Int64?
    var title: String
    var post: String
    var timestamp: String
    var userID: Int64
    var likes: Int64
    

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case post
        case timestamp = "created_at"
        case userID = "user_id"
        case likes
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(post, forKey: .post)
        try container.encode(userID, forKey: .userID)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        post = try container.decode(String.self, forKey: .post)
        timestamp = try container.decode(String.self, forKey: .timestamp)
        userID = try container.decode(Int64.self, forKey: .userID)
        likes = try container.decode(Int64.self, forKey: .likes)
    }
}
