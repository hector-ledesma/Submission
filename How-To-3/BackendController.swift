//
//  BackendController.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/27/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation
import CoreData

class BackendController {
    private var baseURL: URL = URL(string: "https://how-to-application.herokuapp.com/")!

    // Create a new background context so that core data can operate asynchronously
    let bgContext = CoreDataStack.shared.container.newBackgroundContext()

    // The cache will take care of making sure that there are no duplicates within core datta already.
    var cache = Cache<Int64, Post>()

    // This variable will let us store the user for any methods that require their id
    var loggedInUser: User?
    // This array will contain any posts made by the user
    var userPosts: [Post] = []

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

        // As soon as this class gets initialized, populate the cache for existing core data posts.
        populateCache()
    }

    func signUp(username: String, password: String, email: String, completion: @escaping (Bool, URLResponse?, Error?) -> Void) {

        // Make a UserRepresentation with the passed in parameters
        let newUser = UserRepresentation(username: username, password: password, email: email)

        // Build EndPoint URL and create request with URL
        let requestURL = baseURL.appendingPathComponent(EndPoints.register.rawValue)
        var request = URLRequest(url: requestURL)
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

        // MARK: - SignUp Completion Instructions
        /*
         Bool will always be false unless a NEW user was successfully created in the database. Meaning:
            - If bool is true, all other checking can be skipped.
            - An error will only be thrown when something went wrong sending data or decoding the data sent by the server.
            - A response will only be thrown when user already exists.
         */
        dataLoader?.loadData(from: request) { data, response, error in

            if let error = error {
                NSLog("Error sending sign up parameters to server : \(error)")
                completion(false, nil, error)
            }

            if let response = response as? HTTPURLResponse,
                response.statusCode == 500 {
                NSLog("User already exists in the database. Therefore user data was sent successfully to database.")
                completion(false, response, nil)
                return
            }

            guard let data = data else { return }

            let decoder = JSONDecoder()
            do {
                _ = try decoder.decode(UserRepresentation.self, from: data)
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(false, nil, error)
            }

            // We'll only get down here if everything went right
            completion(true, nil, nil)
        }
    }

    // As opposed to the signUp method, all we want the signIn method to give us back is whether or not we logged in.
    // Main reason why I chose to do this, is because we REALLY don't want this token leaving this function
    func signIn(username: String, password: String, completion: @escaping (Bool) -> Void) {

        // Build EndPoint URL and create request with URL
        let requestURL = baseURL.appendingPathComponent(EndPoints.login.rawValue)
        var request = URLRequest(url: requestURL)
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

    // MARK: - Store logged in user methods
    private func storeUser(username: String) throws {
        let requestURL = baseURL.appendingPathComponent(EndPoints.userQuery.rawValue).appendingPathExtension(username)
        var foundError: Error?
        dataLoader?.loadData(from: requestURL) { data, _, error in
            if let error = error {
                NSLog("Error couldn't fetch existing user: \(error)")
                foundError = error
                return
            }
        }
        if let error = foundError {
            throw error
        }
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

    // MARK: - Post Methods
    // TODO: Ask Jon about this

    // This method should never be called directly
    func fetchAllPosts(completion: @escaping ([PostRepresentation]?, Error?) -> Void) throws {

        // If there's no token, user isn't authorized. Throw custom error.
        guard let token = token else {
            throw HowtoError.noAuth("No token in controller. User isn't logged in.")
        }

        let requestURL = baseURL.appendingPathComponent(EndPoints.howTos.rawValue)
        var request = URLRequest(url: requestURL)
        request.httpMethod = Method.get.rawValue
        request.setValue(token.token, forHTTPHeaderField: "Authorization")

        dataLoader?.loadData(from: request, completion: { data, response, error in
            // Always log the status code response from server.
            if let response = response as? HTTPURLResponse {
                NSLog("Server responded with: \(response.statusCode)")
            }

            if let error = error {
                NSLog("Error fetching all existing posts from server : \(error)")
                completion(nil, error)
                return
            }

            // use badData when unwrapping data from server.
            guard let data = data else {
                completion(nil, HowtoError.badData("Bad data received from server"))
                return
            }

            let decoder = JSONDecoder()
            do {
                let posts = try decoder.decode([PostRepresentation].self, from: data)
                completion(posts, nil)
            } catch {
                NSLog("Couldn't decode array of posts from server: \(error)")
                completion(nil, error)
            }
        })
    }

    // This method will let us know if posts have already been downloaded. This will prevent duplicates in core data.
    private func populateCache() {
        
        // First get all existing posts saved to coreData and store them in the Cache
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        // Do this synchronously in the background queue, so that it can't be used until cache is fully populated
        bgContext.performAndWait {
            var fetchResult: [Post] = []
            do {
                fetchResult = try bgContext.fetch(fetchRequest)
            } catch {
                NSLog("Couldn't fetch existing core data posts: \(error)")
            }
            for post in fetchResult {
                cache.cache(value: post, for: post.id)
            }
        }
    }

    // This is the method that should be called.
    // MARK: - Syncin/Load existing Posts Instructions
    /*
     All that needs to be done to sync database to local store is call syncPosts.
     This method takes care of not allowing for duplicates, and updates existing posts.
     - Call this method after user successfully logs in to populate the table for the user.
     */
    func syncPosts(completion: @escaping (Error?) -> Void) {
        var representations: [PostRepresentation] = []
        do {
            try fetchAllPosts { posts, error in
                if let error = error {
                    NSLog("Error fetching all posts to sync : \(error)")
                    completion(error)
                    return
                }

                guard let fetchedPosts = posts else {
                    completion(HowtoError.badData("Posts array couldn't be unwrapped"))
                    return
                }
                representations = fetchedPosts


                // Use this context to initialize new posts into core data.
                self.bgContext.perform {
                    for post in representations {
                        // First if it's in the cache
                        guard let id = post.id else { return }

                        if self.cache.value(for: id) != nil {
                            let cachedPost = self.cache.value(for: id)!
                            self.update(post: cachedPost, with: post)
                        } else {
                            guard let newPost = Post(representation: post, context: self.bgContext) else { return }
                            self.cache.cache(value: newPost, for: newPost .id)
                        }
                    }

                    // After creating all the new posts and updating existing ones, try to save.
                    do {
                        try self.bgContext.save()
                    } catch {
                        NSLog("Error saving background context: \(error)")
                        completion(error)
                    }
                }// context.perform
                completion(nil)

            }// Fetch closure

        } catch {
            completion(error)
        }
    }

    func loadUserPosts() {

    }

    // MARK: - Post CRUD methods

    func update(post: Post, with rep: PostRepresentation) {
        post.title = rep.title
        post.post = rep.post
    }

    // MARK: - Enums

    private enum HowtoError: Error {
        case noAuth(String)
        case badData(String)
    }

    private enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    private enum EndPoints: String {
        case users = "api/user/"
        case userQuery = "api/user/u/search?username="
        case register = "api/auth/register"
        case login = "api/auth/login"
        case howTos = "api/howto"
    }

    // MARK: - THIS METHOD IS ONLY TO BE USED FOR TESTING.
    func injectToken(_ token: String) {
        let token = Token(token: token)
        self.token = token
    }
}

class Cache<Key: Hashable, Value> {
     private var cache: [Key: Value] = [ : ]
     private var queue = DispatchQueue(label: "Cache serial queue")

     func cache(value: Value, for key: Key) {
         queue.async {
             self.cache[key] = value
         }
     }

     func value(for key: Key) -> Value? {
         queue.sync {
            // swiftlint:disable all
             return self.cache[key]
            // swiftlint:enable all
         }

     }
 }
