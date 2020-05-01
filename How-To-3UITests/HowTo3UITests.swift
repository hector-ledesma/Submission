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
        emailTextField.typeText("email@email.com\n")

        let usernameTextField = app.textFields["Username:"]
        usernameTextField.tap()
        usernameTextField.typeText("Username\n")

        let passwordTextField = app.textFields["Password"]
        passwordTextField.tap()
        passwordTextField.typeText("password\n")

    }

    func testLogin() throws {
        let usernameTextField = app.textFields["Username:"]
        usernameTextField.tap()
        usernameTextField.typeText("Username\n")

        let passwordTextField = app.textFields["Password"]
        passwordTextField.tap()
        passwordTextField.typeText("password\n")

        XCUIApplication().staticTexts["Log In"].tap()
    }

    func testMainMenu() {

        app.staticTexts["Log In"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        let makeAGuideStaticText = app.staticTexts["Make a Guide"]
        makeAGuideStaticText.tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        makeAGuideStaticText.tap()
        app.staticTexts["Create Post"].tap()
        app.staticTexts["My Guides"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testDetailView() {
        app.staticTexts["Log In"].tap()
        app.cells.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testMyPostsDetail() {
        app.staticTexts["Log In"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.staticTexts["My Guides"].tap()
        app.cells.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.cells.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 1).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testSignOut() {
        app.staticTexts["Log In"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.staticTexts["Sign Out"].tap()
    }
}
