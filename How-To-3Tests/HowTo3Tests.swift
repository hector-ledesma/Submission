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

    func testSignUp() {
        let backend = BackendController()
        let expect = expectation(description: "got it")
        backend.signUp(username: "Testing", password: "testing", email: "testing@test.com") { data, response, _ in
            XCTAssertNotNil(data)
            guard let data = data else { return }

            var reply: UserRepresentation?

            let decoder = JSONDecoder()
            do {
                let decodedJSON = try decoder.decode(UserRepresentation.self, from: data)
                print(decodedJSON)
                reply = decodedJSON
            } catch {
                NSLog("Error encoding data: \(error)")
            }

            XCTAssertNotNil(reply)
            print(reply)

            expect.fulfill()
        }
        wait(for: [expect], timeout: 10)
    }

    func testFetchUsers() {
        var baseURL: URL = URL(string: "https://how-to-application.herokuapp.com/api/user/")!

    }

}
