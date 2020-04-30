//
//  CreatePostViewController.swift
//  How-To-3
//
//  Created by Bhawnish Kumar on 4/29/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit

class CreatePostViewController: UIViewController {
    
    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    var backendController: BackendController?
    var mainPostTableViewController: MainPostTableViewController?
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        guard let backendController = backendController else { return }
        guard let title = titleTextField.text,
            let date = post?.timestamp,
            let userID = post?.userID,
            let post =  postDescription.text else { return }
            
        backendController.createPost(title: title, post: post) { (error) in
            if let error = error else {
                NSLog("There was an error creating post")
                return
            }
            
            DispatchQueue.main.async {
                if backendController.isSignedIn {
                    title = post
                }
            }
        }
        
    }
    
    private func updateViews() {
        guard let post = post else { return }
        titleTextField.text = post.title
        postDescription.text = post.post
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
