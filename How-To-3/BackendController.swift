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
    init(data: Data?, dataLoader: DataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    //func signUp(username: String, password: String, email: String) {
     //   baseURL.appendPathComponent(<#T##pathComponent: String##String#>)
     //   let request = URLRequest(url: baseURL)
     //   dataLoader?.loadData(from: <#T##URLRequest#>, completion: <#T##(Data?, Error?) -> Void#>)
    //}
    func signIn() {
//        let foo = try! JSONDecoder().decode(UserRepresentation.self, from: data!)
    }

    private enum EndPoints: String {
        case register = "api/auth/register"
        case login = "api/auth/login"
        case howTo = "api/howto"
    }

}
