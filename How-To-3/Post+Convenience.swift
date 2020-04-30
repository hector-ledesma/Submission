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
                                        likes: Int64,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.post = post
        self.timestamp = timestamp
        self.title = title
        self.userID = userID
        self.likes = likes
    }

    @discardableResult convenience init?(representation: PostRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        guard let id = representation.id else {
            NSLog("Representation passed in with invalid id")
            return nil
        }
        self.init(id: id,
                  post: representation.post,
                  timestamp: representation.timestamp,
                  title: representation.title,
                  userID: representation.userID,
                  likes: representation.likes,
                  context: context)
    }
}
