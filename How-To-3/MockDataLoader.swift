//
//  MockDataLoader.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/28/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation

class MockDataLoader: DataLoader {

    var data: Data

    init(data: Data) {
        self.data = data
    }

    func loadData(from request: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        DispatchQueue(label: "Testingqueue").asyncAfter(deadline: .now() + 0.005) {
            completion(self.data, nil)
        }
    }

    func loadData(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        DispatchQueue(label: "Testingqueue").asyncAfter(deadline: .now() + 0.005) {
            completion(self.data, nil)
        }
    }

}
