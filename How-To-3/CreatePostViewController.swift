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
    
    @IBOutlet private weak var postDescription: UITextView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var timeStamp: UILabel!
    
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
            if let error = error {
                NSLog("Error posting posts: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                //Alert
                self.showAlertMessage(title: "Post Created!", message: "Go to the Home", actiontitle: "Ok")
                
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
    
    private func updateViews() {
        guard let newPost = self.post else { return }
        self.titleTextField.text = newPost.title
        self.postDescription.text = newPost.post
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
   private func showAlertMessage(title: String, message: String, actiontitle: String) {
        let endAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let endAction = UIAlertAction(title: actiontitle, style: .default) { (action: UIAlertAction ) in
        }
        
        endAlert.addAction(endAction)
        present(endAlert, animated: true, completion: nil)
    }
    
    
}

