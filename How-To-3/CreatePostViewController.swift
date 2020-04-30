//
//  CreatePostViewController.swift
//  How-To-3
//
//  Created by Bhawnish Kumar on 4/29/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit

class CreatePostViewController: UIViewController, PostPresenter {
    
    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var post: Post?
    var backendController: BackendController?
    var mainPostTableViewController: MainPostTableViewController?
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        guard let backendController = backendController else { return }
        guard let title = titleTextField.text,
                   !title.isEmpty,
                   let bodyText = postDescription.text, !bodyText.isEmpty else {
                       return
               }
        guard let name = post?.userID,
            let id = post?.id,
            let time = post?.timestamp
        else { return }

        backendController.createPost(title: title, post: bodyText) { error in
            if error != nil {
                NSLog("Error in creating posts")
                return
            }
        }
            do {
                    try CoreDataStack.shared.mainContext.save()
                } catch {
                    NSLog("Error saving managed object context: \(error)")
                    return
                }
        print("hi my name is bharat")
               dismiss(animated: true, completion: nil)
       
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
