//
//  How_To_3Tests.swift
//  How-To-3Tests
//
//  Created by Karen Rodriguez on 4/28/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import XCTest
import CoreData
@testable import How_To_3

class HowTo3Tests: XCTestCase {
    // Sorry swiftlint my friend. But there's nothing I can do about this long token lol
    // swiftlint:disable all
    let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJ1c2VybmFtZSI6IlRlc3RpbmcyMiIsImlhdCI6MTU4ODIwMDk0OCwiZXhwIjoxNTg4MjQ0MTQ4fQ.kVzVJ_E4p3u1CC4CvzHjiiFcqFp6wrs1xqnuAp1Qm6k"
    var backend: BackendController!
    let timeout: Double = 10
    // swiftlint:enable all

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        backend = BackendController()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJSONFromDictionary() {
        let dic = ["username": "Lord", "password": "potato"]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            let prettyPrint = String(data: jsonData, encoding: .utf8)
            print(prettyPrint!)
        } catch {
            NSLog("Error creating JSON From Dictionary: \(error)")
            XCTFail("If we couldn't enocde, nor interpret for string, tthen fail test.")
        }
    }

    func testEncodeUserRepresentation() {

        let user = UserRepresentation(username: "Hello", password: "World", email: "What;sup")

        let encoder = JSONEncoder()
        do {
            let json = try encoder.encode(user)
            let pretty = String(data: json, encoding: .utf8)
            print(pretty!)
        } catch {
            XCTFail("No issues encoding json and printing it.")
            NSLog("Error encoding data: \(error)")
        }
    }

    func testSignUp() {
        let expectSignUp = expectation(description: "got it")
        backend.signUp(username: "Testing3", password: "testing", email: "testing3@test.com") { newUser, response, _ in
            if let response = response as? HTTPURLResponse,
            response.statusCode == 500 {
                NSLog("User already exists in the database. Therefore user data was sent successfully to database.")
                expectSignUp.fulfill()
                return
            }
            XCTAssertTrue(newUser)
            expectSignUp.fulfill()
        }
        wait(for: [expectSignUp], timeout: timeout)
    }

    func testSignIn() {
        let expectSignIn = expectation(description: "got it")

        backend.signIn(username: "Testing22", password: "test") { logged in
            XCTAssertTrue(logged)
            expectSignIn.fulfill()
        }

        wait(for: [expectSignIn], timeout: timeout)
        XCTAssertTrue(backend.isSignedIn)

    }

    func testFetchAllPosts() {
        backend.injectToken(token)
        let expectFetchAll = expectation(description: "Fetching posts")

        do {
            try backend.fetchAllPosts { posts, error in
                XCTAssertNil(error)
                XCTAssertNotNil(posts)
                print(posts!)
                expectFetchAll.fulfill()
            }
        } catch {
            expectFetchAll.fulfill()
            XCTFail("No token. Fail.")
        }
        wait(for: [expectFetchAll], timeout: timeout)
    }

    func testSyncPostsCoreData() {
        backend.injectToken(token)
        let syncExpect = expectation(description: "Sync posts expectation.")

        // First pass to check that it works.
        backend.syncPosts { error in
            XCTAssertNil(error)
            syncExpect.fulfill()
        }
        wait(for: [syncExpect], timeout: timeout)

        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        let moc = CoreDataStack.shared.mainContext
        moc.reset()
        var fetchCount: Int = 0
        do {
            let fetchedResults = try moc.fetch(fetchRequest)
            print(fetchedResults.count)
            fetchCount = fetchedResults.count
            XCTAssertFalse(fetchedResults.isEmpty)
        } catch {
            NSLog("Couldn't fetch ----- : \(error)")
            XCTFail("If the result is empy, nothing was fetched.")
        }

        // Second pass to ensure no duplicates are created
        let expect2 = expectation(description: "Expectation for duplicates checking.")
        let newBackend = BackendController()
        newBackend.injectToken(token)
        newBackend.syncPosts { error in
            XCTAssertNil(error)
            expect2.fulfill()
        }
        wait(for: [expect2], timeout: timeout)

        moc.reset()
        do {
            let fetchedResults = try moc.fetch(fetchRequest)
            print(fetchedResults.count)
            // Check that the previously assigned count is the same as this new fetch count
            XCTAssertEqual(fetchCount, fetchedResults.count)
        } catch {
            NSLog("Couldn't fetch ----- : \(error)")
            XCTFail("If the result is empy, nothing was fetched.")
        }
    }

    func testStoreUserID() {
        let expectStoreUser = expectation(description: "Testing stored user.")
        backend.signIn(username: "Testing22", password: "test") { _  in
            expectStoreUser.fulfill()
        }
        wait(for: [expectStoreUser], timeout: timeout)
        XCTAssertTrue(backend.isSignedIn)
        XCTAssertNotNil(backend.loggedUserID)
    }

    func testLoadUserPosts() {
//        let backend = BackendController()
        let expectLoadUserPosts = expectation(description: "Testing stored user.")
        backend.signIn(username: "Testing22", password: "test") { _  in
            expectLoadUserPosts.fulfill()
        }
        wait(for: [expectLoadUserPosts], timeout: timeout)
        XCTAssertTrue(backend.isSignedIn)
        let expec2 = expectation(description: "Force load posts")
        backend.forceLoadUserPosts(completion: { isEmpty, error in
            XCTAssertNil(error)
            XCTAssertTrue(!isEmpty)
            expec2.fulfill()
        })
        wait(for: [expec2], timeout: timeout)
        print(backend.userPosts)
        XCTAssertTrue(!backend.userPosts.isEmpty)
    }

    func testCreatePost() {
        let expectCreatePost = expectation(description: "Testing create new post.")
        backend.signIn(username: "Testing22", password: "test") { _ in
            expectCreatePost.fulfill()
        }
        wait(for: [expectCreatePost], timeout: timeout)
        let count = backend.userPosts.count
        print(count)
        let createExpect = expectation(description: "Expectation for creating post")
        backend.createPost(title: "New post for testing at 4 AM", post: "From testing grounds") { error in
            XCTAssertNil(error)
            createExpect.fulfill()
        }
        wait(for: [createExpect], timeout: timeout)

        let refetchUserExpect = expectation(description: "Last expectation for testing create post")
        backend.forceLoadUserPosts { isEmpty, error in
            XCTAssertFalse(isEmpty)
            XCTAssertNil(error)
            refetchUserExpect.fulfill()
        }
        wait(for: [refetchUserExpect], timeout: timeout)
        XCTAssertTrue(count < backend.userPosts.count)
    }

    func testUpdatePost() {
        let expectUpdatePost = expectation(description: "Testing update post.")
        backend.signIn(username: "Testing22", password: "test") { _ in
            expectUpdatePost.fulfill()
        }
        wait(for: [expectUpdatePost], timeout: timeout)

        let refetchUserExpectation = expectation(description: "Last method call for testing update post")
        backend.forceLoadUserPosts { _, _ in
            refetchUserExpectation.fulfill()
        }
        wait(for: [refetchUserExpectation], timeout: timeout)
        print(backend.userPosts)

        let updateExpect = expectation(description: "Expectation for updating post")
        backend.updatePost(at: backend.userPosts[0], title: "Post has been updated from test!", post: "From testing grounds") { error in
            XCTAssertNil(error)
            updateExpect.fulfill()
        }
        wait(for: [updateExpect], timeout: timeout)
    }

    func testDeletePost() {

        let deleteSignexpectation = expectation(description: "Signing in to delete a post.")
        backend.signIn(username: "Testing22", password: "test") { loggedIn in
            deleteSignexpectation.fulfill()
        }
        wait(for: [deleteSignexpectation], timeout: timeout)

        // We'll populate the user's posts so we can use the first post in the array for deletion.
        let loadToDeleteExpect = expectation(description: "Load user posts so we may delete one.")
        backend.forceLoadUserPosts { _, _ in
            loadToDeleteExpect.fulfill()
        }
        wait(for: [loadToDeleteExpect], timeout: timeout)

        let deletePostExpect = expectation(description: "Delete post method expectation")
        backend.deletePost(post: backend.userPosts[0]) { deleted, error in
            XCTAssertNil(error)
            XCTAssertNotNil(deleted)
            // Consider the not nil check as unwrapping, so force unwrapping is safe
            XCTAssertTrue(deleted!)
            deletePostExpect.fulfill()
        }
        wait(for: [deletePostExpect], timeout: timeout)
    }

    func testFetchAuthorName() {
        let authorExpec = expectation(description: "Getting author name from ID")
        backend.postAuthorName(id: 21) { author, error in
            XCTAssertNil(error)
            XCTAssertNotNil(author)
            XCTAssertEqual(author!, "Testing22")
            authorExpec.fulfill()
        }
        wait(for: [authorExpec], timeout: timeout)
    }
}
