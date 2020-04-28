//
//  BackendController.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/27/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation

class BackendController {
    private var baseURL: URL = URL(string: "https://how-to-application.herokuapp.com/")!
    private var token: Token?
    var dataLoader: DataLoader?

    // If the initializer isn't provided with a data loader, simply use the URLSession singleton.
    init(dataLoader: DataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    func signUp(username: String, password: String, email: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {

        // Make a UserRepresentation with the passed in parameters
        let newUser = UserRepresentation(username: username, password: password, email: email)

        // Build EndPoint URL and create request with URL
        baseURL.appendPathComponent(EndPoints.register.rawValue)
        var request = URLRequest(url: baseURL)
        request.httpMethod = Method.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()

            // Try to encode the newly created user into the request body.
            let jsonData = try encoder.encode(newUser)
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding newly created user: \(error)")
            return
        }
        print(request.httpBody)
        dataLoader?.loadData(from: request, completion: { data, response, error in
            completion(data, response, error)
        })
    }
    func signIn() {
//        let foo = try! JSONDecoder().decode(UserRepresentation.self, from: data!)
    }

    private enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    private enum EndPoints: String {
        case users = "api/user/"
        case register = "api/auth/register"
        case login = "api/auth/login"
        case howTos = "api/howto"
    }

}
