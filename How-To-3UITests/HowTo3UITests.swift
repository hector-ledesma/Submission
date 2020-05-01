//
//  How_To_3UITests.swift
//  How-To-3UITests
//
//  Created by Karen Rodriguez on 4/28/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import XCTest

class HowTo3UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTextFields() {

        let emailTextField = app.textFields["Email:"]
        emailTextField.tap()
        emailTextField.typeText("email@email.com")

        let usernameTextField = app.textFields["Username:"]
        usernameTextField.tap()
        usernameTextField.typeText("Username")

        let passwordTextField = app.textFields["Password"]
        passwordTextField.tap()
        passwordTextField.typeText("password")

    }

    func testLogin() throws {
        // UI tests must launch the application that they test.

        let usernameTextField = app.textFields["Username:"]
        usernameTextField.tap()
        usernameTextField.typeText("Username")

        let passwordTextField = app.textFields["Password"]
        passwordTextField.tap()
        passwordTextField.typeText("password")

        XCUIApplication().keyboards.buttons["Hide keyboard"].tap()

        XCUIApplication().staticTexts["Log In"].tap()


        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
