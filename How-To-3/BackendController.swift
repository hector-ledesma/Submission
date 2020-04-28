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
    init(data: Data?, dataLoader: DataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    func signUp(username: String, password: String, email: String) {

        // Make a UserRepresentation with the passed in parameters
        let newUser = UserRepresentation(id: nil, username: username, password: password, email: email)

        // Build EndPoint URL and create request with URL
        baseURL.appendPathComponent(EndPoints.register.rawValue)
        var request = URLRequest(url: baseURL)

        do {
            let encoder = JSONEncoder()

            // Try to encode the newly created user into the request body.
            request.httpBody = try encoder.encode(newUser)
        } catch {
            NSLog("Error encoding newly created user: \(error)")
            return
        }

        dataLoader?.loadData(from: request, completion: { data, error in
            print(data)
        })
    }
    func signIn() {
//        let foo = try! JSONDecoder().decode(UserRepresentation.self, from: data!)
    }

    private enum EndPoints: String {
        case users = "api/user/"
        case register = "api/auth/register"
        case login = "api/auth/login"
        case howTos = "api/howto"
    }

}
