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
    
    var post: Post?
    var backendController: BackendController?
    var mainPostTableViewController: MainPostTableViewController?
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        guard let backendController = backendController,
                   let title = titleTextField.text,
                   let author = post?.userID,
                   let time = post?.timestamp,
            let bodyPost = postDescription.text,
                   let id = post?.id
               else { return }
           
               backendController.createPost(title: title, post: bodyPost) { error in
                   if error != nil {
                       NSLog("Could not load posts")
                       return
                   }
                   DispatchQueue.main.async {
                   
                   let newPost = Post(id: id, post: bodyPost, timestamp: time, title: title, userID: author)
                    self.mainPostTableViewController?.
                    self.mainPostTableViewController?.tableView.reloadData()
                   }
               }
               do {
                   try CoreDataStack.shared.mainContext.save()
               } catch {
                   NSLog("error in loading post")
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
