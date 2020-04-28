//
//  DataLoader.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/27/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation

// This protocol lets us use dependency injection. This way we can handle mock data within our app.
protocol DataLoader {
    // All we need is for these methods to return Data or Errors once they're done. These methods MUST be implemented using asynchrony, therefore all returned data will be handled in completion closures.
    func loadData(from request: URLRequest, completion: @escaping(Data?, Error?) -> Void)
    func loadData(from url: URL, completion: @escaping(Data?, Error?) -> Void)
}
