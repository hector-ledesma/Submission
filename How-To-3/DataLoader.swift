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

// MARK: - URLSession:
/*
    URLSession is the class that lets us decide how our DataTasks will be configured. At the end of the day, what actually connects to the servers are URLSessionDataTask(s):
    - That is to say, a URLSessionDataTask is an object/class that takes care of doing network call asynchronously.
    - If you check the method for dataTask, all it does is return a URLSessionDataTask object.
    - The closure is basically handling what that newly create object returns.
 */

extension URLSession: DataLoader {
    // When nesting completion handlers, remember that we're sending data to wherever the top layered method is called.
    // Always remember to call completion with only the data you want sent back.
    func loadData(from request: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        // Create a DataTask with the request:
        // - An URLRequest can be built up to contain headers and encoded data in the body.

        // We use this when we want to send data to the server
        dataTask(with: request) { data, _, error in
            // We can choose to handle the usual checking for data or error in here.
            // But we can also worry about handling that within whichever controller uses these methods.
            // This gives rooom for custom error handling and data handling if the app was much larger in scale.
            // Here we'll need it because we're handling Posts and User network requests separately.
            completion(data, error)
        }.resume()
    }

    // Create a DataTask with just an URL: This is good if all we care about is pinging the server without any data.
    func loadData(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        dataTask(with: url) { data, _, error in
            completion(data, error)
        }.resume()
    }

}
