//
//  Post+Codable.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/27/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation

class PostRepresentation: Decodable {

    enum CodingKeys: String, CodingKey {
        case timestamp = "created_at"
    }

    let jsonDecoder = JSONDecoder()

    func test() {
        try! jsonDecoder.decode(PostRepresentation.self, from: <#T##Data#>)
    }

    required init(from decoder: Decoder) throws {

    }
}
