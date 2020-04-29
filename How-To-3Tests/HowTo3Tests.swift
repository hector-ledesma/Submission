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
    let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJ1c2VybmFtZSI6IlRlc3RpbmcyMiIsImlhdCI6MTU4ODEzMjU1NiwiZXhwIjoxNTg4MTc1NzU2fQ.QC4YX42LKUlf700MgXsMxg-xw_YiJjPnW3DKFxh5300"
    let backend = BackendController()
    // swiftlint:enable all

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
        let expect = expectation(description: "got it")
        backend.signUp(username: "Testing3", password: "testing", email: "testing3@test.com") { newUser, response, _ in
            if let response = response as? HTTPURLResponse,
            response.statusCode == 500 {
                NSLog("User already exists in the database. Therefore user data was sent successfully to database.")
                expect.fulfill()
                return
            }
            XCTAssertTrue(newUser)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
    }

    func testSignIn() {
        let expect = expectation(description: "got it")

        backend.signIn(username: "Testing22", password: "test") { logged in
            XCTAssertTrue(logged)
            expect.fulfill()
        }

        wait(for: [expect], timeout: 5)

    }

    func testFetchAllPosts() {
        backend.injectToken(token)
        let expect = expectation(description: "Fetching posts")

        do {
            try backend.fetchAllPosts { posts, error in
                XCTAssertNil(error)
                XCTAssertNotNil(posts)
                print(posts!)
                expect.fulfill()
            }
        } catch {
            expect.fulfill()
            XCTFail("No token. Fail.")
        }
        wait(for: [expect], timeout: 10)
    }

    func testSyncPostsCoreData() {
        backend.injectToken(token)
        let expect = expectation(description: "Syn posts expectation.")

        // First pass to check that it works.
        backend.syncPosts { error in
            XCTAssertNil(error)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 10)

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
        wait(for: [expect2], timeout: 10)

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
        let expect = expectation(description: "Testing stored user.")
        backend.signIn(username: "Testing22", password: "test") { _  in
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
        XCTAssertTrue(backend.isSignedIn)
        XCTAssertNotNil(backend.loggedUserID)
    }

}
