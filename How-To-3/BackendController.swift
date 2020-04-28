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

    // MARK: - Token Instructions
    private var token: Token?
    // If there's no token, it will return false and viceversa
    var isSignedIn: Bool {
        // swiftlint: disable all
        return token != nil
        // swiftlint: enable all
    }
    /*
     The isSignedIn property should be used EVERYWHERE:
        - Segues should only work if isSignedIn is true.
        - Views should only be rendered into the screen if isSignedIn is true.
        - Etc.
     If at any point isSignedIn is false, the else clause should popthe navigation controller back to the first controller.
     e.g:
        if isSignedIn {
            Load everything
        } else {
            Use exit connection to send user back to log in screen
        }
     */
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
        dataLoader?.loadData(from: request, completion: { data, _, error in
            if let error = error {
                NSLog("Error logging in. \(error)")
                completion(self.isSignedIn)
                return
            }

            guard let data = data else {
                NSLog("Invalid data received while loggin in.")
                completion(self.isSignedIn)
                return
            }

            do {
                let decoder = JSONDecoder()
                let tokenResult = try decoder.decode(Token.self, from: data)
                self.token = tokenResult
                completion(self.isSignedIn)
            } catch {
                NSLog("Error decoding received token. \(error)")
                completion(self.isSignedIn)
            }
        })

        // MARK: - SignIn Instructions
        /*
         As we really don't want the token to leave this controller, all you'll need is to check if user is signed in is:
            - Is token nil? Use isSignedIn property. If it is nil, then user isn't logged in.
            - If user isn't logged in, use signIn method. The completion closure will return true only after a token has been successfully saved.
         */
    }

    // MARK: - Sign Out Instructions
    func signOut() {
        // All we check to see if we're logged in is whether or not we have a token.
        // Therefore all we need to do to log out, is get rid of our token.
        self.token = nil
    }

    private func jsonFromDict(username: String, password: String) throws -> Data? {
        var dic: [String: String] = [:]
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
