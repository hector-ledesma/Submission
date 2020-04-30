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
    // Instead of constantly creating and deleting decoders and encoders, just make one of each and use them around the app.
    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()

    // Create a new background context so that core data can operate asynchronously
    let bgContext = CoreDataStack.shared.container.newBackgroundContext()
    let operationQueue = OperationQueue()

    // The cache will take care of making sure that there are no duplicates within core datta already
    var cache = Cache<Int64, Post>()

    // This variable will let us store the user id for any methods that require it
    var userID: Int64? {
        didSet {
            loadUserPosts()
        }
    }
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

            do {
                _ = try self.decoder.decode(UserRepresentation.self, from: data)
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

            self.bgContext.perform {
                do {
                    let tokenResult = try self.decoder.decode(Token.self, from: data)
                    self.token = tokenResult
                    self.storeUser(username: username) { _ in
                        completion(self.isSignedIn)
                    }
                } catch {
                    NSLog("Error decoding received token. \(error)")
                    completion(self.isSignedIn)
                }
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
        // As we've added userID and Posts, clear those out on signOut as well
        self.userID = nil
        self.userPosts = []
    }

    // MARK: - Store Signed in user methods

    // This method will take care of storing the user ID. It will be called right after a successful Sign In.
    private func storeUser(username: String, completion: @escaping (Error?) -> Void) {
        let requestURL = baseURL.appendingPathComponent(EndPoints.userSearch.rawValue)
        var request = URLRequest(url: requestURL)
        request.httpMethod = Method.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let data = try jsonFromUsername(username: username)
            request.httpBody = data

        } catch {
            NSLog("Error creating json for finding user by username: \(error)")
            return
        }

        dataLoader?.loadData(from: request) { data, _, error in
            if let error = error {
                NSLog("Error couldn't fetch existing user: \(error)")
                completion(error)
                return
            }

            guard let data = data else {
                let error = HowtoError.badData("Invalid data returned from searching for a specific user.")
                completion(error)
                return
            }

            do {
                if let decodedUser = try self.decoder.decode([UserRepresentation].self, from: data).first {
                    self.userID = decodedUser.id
                    completion(nil)
                }
            } catch {
                NSLog("Couldn't decode user fetched by username: \(error)")
                completion(error)
            }
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
    private func jsonFromUsername(username: String) throws -> Data? {
        var dic: [String: String] = [:]
        dic["username"] = username

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            return jsonData
        } catch {
            NSLog("Error Creating JSON From username dictionary. \(error)")
            throw error
        }

    }
    private func jsonFromDicct(dict: [String: Any]) throws -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            return jsonData
        } catch {
            NSLog("Error Creating JSON From username dictionary. \(error)")
            throw error
        }
    }

    // MARK: - Post Methods

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

            do {
                let posts = try self.decoder.decode([PostRepresentation].self, from: data)
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
                            do {
                                try self.savePost(by: id, from: post)
                            } catch {
                                completion(error)
                                return
                            }
                        }
                    }
                }// context.perform
                completion(nil)
            }// Fetch closure

        } catch {
            completion(error)
        }
    }

    // This post shouldn't really be called, but it'll stay public just in case it's needed.
    func syncSinglePost(with representation: PostRepresentation) {
        guard let id = representation.id else { return }

        if let cachedPost = self.cache.value(for: id) {
            self.update(post: cachedPost, with: representation)
        } else {
            do {
                try self.savePost(by: id, from: representation)
            } catch {
                NSLog("Error syncinc single post: \(error)")
                return
            }
        }
    }

    // This function will be called by a didset in userID
    // As given that the function that populates core data checks for duplicates, we don't need to worry about that.
    private func loadUserPosts(completion: @escaping (Bool, Error?) -> Void = { _, _ in }) {
        guard let id = userID,
        let token = token else {
            completion(false, HowtoError.noAuth("UserID hasn't been assigned"))
            return
        }
        let requestURL = baseURL.appendingPathComponent("\(EndPoints.userPosts.rawValue)\(id)")
        var request = URLRequest(url: requestURL)
        request.httpMethod = Method.get.rawValue
        request.setValue(token.token, forHTTPHeaderField: "Authorization")

        dataLoader?.loadData(from: request) { data, _, error in
            if let error = error {
                NSLog("Error fetching logged in user's posts : \(error)")
                completion(false, error)
                return
            }

            guard let data = data else {
                completion(false, HowtoError.badData("Received bad data when fetching logged in user's posts array."))
                return
            }

            let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()

//            self.bgContext.performAndWait {
                let handleFetchedPosts = BlockOperation {
                    do {
                        let decodedPosts = try self.decoder.decode([PostRepresentation].self, from: data)
                        // Check if the user has no posts. And if so return right here.
                        if decodedPosts.isEmpty {
                            NSLog("User has no posts in the database.")
                            completion(true, nil)
                            return
                        }
                        // If the decoded posts array isn't empty
                        for post in decodedPosts {
                            guard let postID = post.id else { return }
                            let nsID = NSNumber(integerLiteral: Int(postID))
                            fetchRequest.predicate = NSPredicate(format: "id == %@", nsID)
                            // If fetch request finds a post, add it to the array and update it in core data
                            if let foundPost = try self.bgContext.fetch(fetchRequest).first {
                                self.update(post: foundPost, with: post)
                                self.userPosts.append(foundPost)
                            } else {
                                //                             If the post isn't in core data, add it.
                                if let newPost = Post(representation: post, context: self.bgContext) {
                                    self.userPosts.append(newPost)
                                }
                                //                            try self.savePost(by: id, from: post)
                            }
                        }
                    } catch {
                        NSLog("Error Decoding posts, Fetching from Coredata: \(error)")
                        completion(false, error)
                    }
                }

                let handleSaving = BlockOperation {
                    do {
                        // After going through the entire array, try to save context.
                        // Make sure to do this in a separate do try catch so we know where things fail
                        let handleSaving = BlockOperation {
                            do {
                                // After going through the entire array, try to save context.
                                // Make sure to do this in a separate do try catch so we know where things fail
                                try CoreDataStack.shared.save(context: self.bgContext)
                                completion(false, nil)
                            } catch {
                                NSLog("Error saving context. \(error)")
                                completion(false, error)
                            }
                        }
                        self.operationQueue.addOperations([handleSaving], waitUntilFinished: true)
                    } catch {
                        NSLog("Error saving context.")
                        completion(false, error)
                    }
                }
                handleSaving.addDependency(handleFetchedPosts)
                self.operationQueue.addOperations([handleFetchedPosts, handleSaving], waitUntilFinished: true)
//            }
        }
    }

    // MARK: - Signed In User's Posts Instructions
    /*
     The userPosts property will automatically be populated once a user is successfully signed in.
     Therefore, refer to userPosts.count to tell the user if they have no posts.
     Create a refresh posts button that allows the user to call this method.
     This bethod returns:
        - True if the user has no posts in the database.
        - False and an error if something went wrong.
        - If false and no error, userPosts was successfully populated.
     */
    func forceLoadUserPosts(completion: @escaping (Bool, Error?) -> Void) {
        loadUserPosts(completion: { isEmpty, error in
                completion(isEmpty, error)
            })
    }

    // MARK: - Create New Post Instructions
    /*
     This function will ONLY work if the user is signed in.
     What you need to pass in when calling this method is simply:
        - Title
        - Content of post
     The post will take care of merging with core data, and updating cache.
     Closure only returns an error, therefore:
        - If completion returns no error, everything went ok and you're free to reload view.
     */
    func createPost(title: String, post: String, completion: @escaping (Error?) -> Void) {
        guard let id = userID,
            let token = token else {
            completion(HowtoError.noAuth("No userID stored in the controller. Can't create new post."))
            return
        }

        let requestURL = baseURL.appendingPathComponent(EndPoints.howTos.rawValue)
        var request = URLRequest(url: requestURL)
        request.httpMethod = Method.post.rawValue
        request.setValue(token.token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let dict: [String : Any] = ["title":title, "post":post, "user_id":id]
            request.httpBody = try jsonFromDicct(dict: dict)
        } catch {
            NSLog("Error turning dictionary to json: \(error)")
            completion(error)
        }

        dataLoader?.loadData(from: request, completion: { data, _, error in
            if let error = error {
                NSLog("Error posting new post to database : \(error)")
                completion(error)
                return
            }

            guard let data = data else {
                completion(HowtoError.badData("Server send bad data when creating new post."))
                return
            }

            self.bgContext.perform {
                do {
                    let post = try self.decoder.decode(PostRepresentation.self, from: data)
                    self.syncSinglePost(with: post)
                    completion(nil)
                } catch {
                    NSLog("Error decoding fetched posts from database: \(error)")
                    completion(error)
                }
            }

        })
    }

    // MARK: - Post CRUD methods

    private func savePost(by userID: Int64, from representation: PostRepresentation) throws {
        if let newPost = Post(representation: representation, context: bgContext) {
            let handleSaving = BlockOperation {
                do {
                    // After going through the entire array, try to save context.
                    // Make sure to do this in a separate do try catch so we know where things fail
                    try CoreDataStack.shared.save(context: self.bgContext)
                } catch {
                    NSLog("Error saving context.\(error)")
                }
            }
            operationQueue.addOperations([handleSaving], waitUntilFinished: false)
            cache.cache(value: newPost, for: userID)
        }
    }

    // MARK: - Update Post Instructions
    /*
     Aside from very tiny tweaks, this is almost the exact same code as in the createPost method.
     So refer to those instructions for using this method.
     */
    func updatePost(at post: Post, title: String, post description: String, completion: @escaping (Error?) -> Void) {
        guard let id = userID,
            let token = token else {
                completion(HowtoError.noAuth("User is not logged in."))
                return
        }

        let requestURL = baseURL.appendingPathComponent(EndPoints.howTos.rawValue).appendingPathComponent("\(post.id)")
        var request = URLRequest(url: requestURL)
        request.httpMethod = Method.put.rawValue
        request.setValue(token.token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let dict: [String : Any] = ["title":title, "post":description, "user_id":id]
            request.httpBody = try jsonFromDicct(dict: dict)
        } catch {
            NSLog("Error turning dictionary to json: \(error)")
            completion(error)
        }

        dataLoader?.loadData(from: request, completion: { data, _, error in
            if let error = error {
                NSLog("Error posting new post to database : \(error)")
                completion(error)
                return
            }

            guard let data = data else {
                completion(HowtoError.badData("Server sent bad data when updating post."))
                return
            }

            self.bgContext.perform {
                do {
                    let post = try self.decoder.decode(PostRepresentation.self, from: data)
                    self.syncSinglePost(with: post)
                    completion(nil)
                } catch {
                    NSLog("Error decoding fetched posts from database: \(error)")
                    completion(error)
                }
            }

        })
    }

    private func update(post: Post, with rep: PostRepresentation) {
        post.title = rep.title
        post.post = rep.post
    }

    // MARK: - Delete Post Instructions
    /*
     This will be the only methos that:
        1. Uses query parameters
        2. Returns a number to determine bool valuse

     The closure returns:
        1. Only an error if something went wrong
        2. Only a bool value if we communicated with the server successfully:
            A. It will return True if we deleted the chosen post
            B. False if the server wasn't able to delete the post
            C. BOTH! ONLY IF: We successfully deleted from the server, but were unable to delete from Core Data
     */
    func deletePost(post: Post, completion: @escaping (Bool?, Error?) -> Void) {
        guard let id = userID,
        let token = token else {
            completion(nil, HowtoError.noAuth("User not logged in."))
            return
        }

        // Our only DELETE endpoint utilizes query parameters.
        // Must use a new URL to construct commponents

        var requestURL = URLComponents(string: "https://how-to-application.herokuapp.com/api/howto/\(post.id)/delete")!
        requestURL.queryItems = [
            URLQueryItem(name: "user_id", value: String(id))
        ]

        var request = URLRequest(url: requestURL.url!)
        request.httpMethod = Method.delete.rawValue
        request.setValue(token.token, forHTTPHeaderField: "Authorization")

        dataLoader?.loadData(from: request, completion: { data, _, error in
            if let error = error {
                NSLog("Error from server when attempting to delete. : \(error)")
                completion(nil, error)
                return
            }

            guard let data = data else {
                NSLog("Error unwrapping data sent form server: \(error)")
                completion(nil, HowtoError.badData("Bad data from server when deleting."))
                return
            }

            var success: Bool = false

            do {
                let response = try self.decoder.decode(Int.self, from: data)
                success = response == 1 ? true : false
                if success { self.bgContext.delete(post) }
                completion(success, nil)
            } catch {
                NSLog("Error decoding response from server after deleting: \(error)")
                completion(nil, error)
                return
            }

        })
    }

    // MARK: - MISC Methods

    // MARK: - Author's Name Instructions
    /*
     This method will return the name of the author as an optional string. or an Error.
     Use the optional string if there's no error to assign name of author to cell.
     */
    func postAuthorName(id: Int64, completion: @escaping (String?, Error?) -> Void) {
        let requestURL = baseURL.appendingPathComponent("\(EndPoints.users.rawValue)\(id)")

        dataLoader?.loadData(from: requestURL, completion: { data, _, error in
            if let error = error {
                NSLog("Error from server : \(error)")
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, HowtoError.badData("Bad data from server when fetching user by ID"))
                return
            }

            do {
                if let decodedUser = try self.decoder.decode([UserRepresentation].self, from: data).first {
                    completion(decodedUser.username, nil)
                }
            } catch {
                NSLog("Error decoding user from server response: \(error)")
                completion(nil, error)
            }
        })
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
        case userSearch = "api/user/u/search"
        case userPosts = "api/howto/user/"
        case register = "api/auth/register"
        case login = "api/auth/login"
        case howTos = "api/howto"
    }

    // MARK: - THESE METHODS ARE ONLY TO BE USED FOR TESTING.
    func injectToken(_ token: String) {
        let token = Token(token: token)
        self.token = token
    }

    func loggedUserID() -> Int64? {
        // swiftlint:disable all
        return self.userID
        // swiftlint:enable all
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
