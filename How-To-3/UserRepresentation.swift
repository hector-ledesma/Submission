//
//  UserRepresentation.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/27/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation

/* Given the structure of our back end, only need custom encodable that ignores id and email because:
    - We'll never need to encode our User data when creating - as we send data before storing in coreData
    - We'll only encode data when Logging in : We have to send our existing CoreData user's username and password while ignoring everything else so that we may receive a matching token.
    - We'll only decode data when signingUp. At which point we'll need all these properties.
 */

struct UserRepresentation: Codable {

    var id: Int64?
    var username: String
    var password: String
    var email: String

    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case password
        case email
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username,  forKey: .username)
        try container.encode(password,  forKey: .password)
        try container.encode(email,     forKey: .email)
    }

    init(username: String, password: String, email: String, id: Int64? = nil) {
        self.id = id
        self.username = username
        self.password = password
        self.email = email

    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedID  = try container.decode(Int.self, forKey: .id)
        id = Int64(decodedID)
        username = try container.decode(String.self, forKey: .username)
        password = try container.decode(String.self, forKey: .password)
        email = try container.decode(String.self, forKey: .email)
    }
}
