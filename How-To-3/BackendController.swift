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
        dataLoader?.loadData(from: request, completion: { data, response, error in
            completion(data, response, error)
        })
    }

    // As opposed to the signUp method, all we want the signIn method to give us back is whether or not we logged in.
    // Main reason why I chose to do this, is because we REALLY don't want this token leaving this function
    func signIn(username: String, password: String, completion: @escaping (Bool) -> Void) {

        // Build EndPoint URL and create request with URL
        baseURL.appendPathComponent(EndPoints.login.rawValue)
        var request = URLRequest(url: baseURL)
        request.httpMethod = Method.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            // Try to create a JSON from the passaed in parameters, and embedding it into requestHTTPBody.
            let jsonData = try jsonFromDict(username: username, password: password)
            request.httpBody = jsonData
        } catch {
            NSLog("Error creating json from passed in username and password: \(error)")
            return
        }
        dataLoader?.loadData(from: request, completion: { data, response, error in
            if let error = error {
                NSLog("Error logging in. \(error)")
                completion(false)
                return
            }

            guard let data = data else {
                NSLog("Invalid data received while loggin in.")
                completion(false)
                return
            }

            do {
                let decoder = JSONDecoder()
                let tokenResult = try decoder.decode(Token.self, from: data)
                self.token = tokenResult
                completion(true)
            } catch {
                NSLog("Error decoding received token. \(error)")
                completion(false)
            }
        })
    }

    private func jsonFromDict(username: String, password: String) throws -> Data?  {
        var dic: [String:String] = [:]
        dic["username"] = username
        dic["password"] = password

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            return jsonData
        } catch {
            NSLog("Error Creating JSON from Dictionary. \(error)")
            throw error
        }
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
