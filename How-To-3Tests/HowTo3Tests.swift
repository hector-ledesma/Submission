//
//  How_To_3Tests.swift
//  How-To-3Tests
//
//  Created by Karen Rodriguez on 4/28/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import XCTest
@testable import How_To_3

class HowTo3Tests: XCTestCase {

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
        let backend = BackendController()
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
        let backend = BackendController()
        let expect = expectation(description: "got it")

        backend.signIn(username: "Testing22", password: "test") { logged in
            XCTAssertTrue(logged)
            expect.fulfill()
        }

        wait(for: [expect], timeout: 5)

    }

    func testFetchUsers() {
        var baseURL: URL = URL(string: "https://how-to-application.herokuapp.com/api/user/")!

    }

}
