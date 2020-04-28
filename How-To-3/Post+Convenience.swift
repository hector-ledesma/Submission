//
//  Post+Convenience.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/27/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation
import CoreData

extension Post {
    @discardableResult convenience init(id: Int64,
                                        post: String,
                                        timestamp: String,
                                        title: String,
                                        userID: Int64,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.post = post
        self.timestamp = timestamp
        self.title = title
        self.userID = userID
    }
}
