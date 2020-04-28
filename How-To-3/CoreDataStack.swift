//
//  CoreDataStack.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/27/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    // Create private initializer
    private init() {}

    // Create the singleton instance of this stack.
    static let shared = CoreDataStack()

    // The container sets up the model, context and store coordinator all at once.
    var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Refresh")

        // First we want to load what we have.
        container.loadPersistentStores { _, error in
            // Unwrap the error, but don't nuke the app.
            if let error = error {
                NSLog("Couldn't load items from persistent store : \(error)")
            }
        }

        // This will automatically update things whenever we change CoreData.
        // Don't do it for an app that may contain a ton of entries.
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }()

    // A context tracks changes to instances of your app as it's seen by that context.
    // So there can be more than one context, all with their own copy of your model. They sync once you save to persistent store.
    // We waint quick access to the main context, from the container we'll be working with.
    var mainContext: NSManagedObjectContext {
        container.viewContext
    }

    // In the words of Stourstroup: "Let the called function catch the error. Let the Function Caller handle the error." or something like that lol idk
    // This function lets us reduce the overhead when saving a context.
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        // We have to craft our own error object
        var saveError: Error?

        // Perform and wait forces the called block to be performed synchronously within the context's queue.
        context.performAndWait {
            do {
                try context.save()
            } catch {
                saveError = error
            }
        }
        if let error = saveError { throw error }
    }

}
