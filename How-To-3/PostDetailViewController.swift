//
//  PostDetailViewController.swift
//  How-To-3
//
//  Created by Bhawnish Kumar on 4/28/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import CoreData
class PostDetailViewController: UIViewController {

    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var authorName: UILabel!
    
    var postRepresentation: PostRepresentation? {
        didSet {
            updateViews()
        }
    }
    var post: Post?
    var backendController: BackendController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func likesButtonPressed(_ sender: UIButton) {
//        var likes = []
//        if sender.isSelected {
//        }
    }
    
    
    private func updateViews() {
        guard let postRepresentation = postRepresentation else { return }
        guard let post = post else { return }
        postDescription.text = postRepresentation.title
        timeStamp.text = postRepresentation.timestamp
        authorName.text = String(postRepresentation.userID)
        
        backendController?.syncSinglePost(with: postRepresentation)
        do {
           try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Couldn't update the views")
            return 
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
