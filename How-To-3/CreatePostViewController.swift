//
//  CreatePostViewController.swift
//  How-To-3
//
//  Created by Bhawnish Kumar on 4/29/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import CoreData
class CreatePostViewController: UIViewController, PostPresenter {
    
    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    var backendController: BackendController?
    var mainPostTableViewController: MainPostTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text,
            !title.isEmpty,
            let backendController = backendController,
            let bodyText = postDescription.text, !bodyText.isEmpty else {
                return
        }
        
        backendController.createPost(title: title, post: bodyText) { error in
            if error != nil {
                NSLog("Error posting posts")
                return
            }
        }
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
            return
        }
        navigationController?.dismiss(animated: true, completion: nil)
        
        
    }
    
    func updateViews() {
        guard let newPost = self.post else { return }
        self.titleTextField.text = newPost.title
        self.postDescription.text = newPost.post
        self.authorLabel.text = String(newPost.userID)
        self.timeStamp.text = newPost.timestamp
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func addPost(user userId: Int64) -> String {
        
        return String(post!.userID)
    }
    
}
