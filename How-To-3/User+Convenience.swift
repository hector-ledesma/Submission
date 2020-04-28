//
//  User+Convenience.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/27/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation
import CoreData

extension User {

    @discardableResult convenience init(id: Int64,
                                        username: String,
                                        email: String,
                                        password: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.username = username
        self.email = email
        self.password = password
    }
}
