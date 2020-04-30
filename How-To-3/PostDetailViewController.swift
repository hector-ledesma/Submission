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

    // MARK: - Properties

    // MARK: - Outlets

    // MARK: - Protocol Conforming

    // MARK: - Custom Methods

    // MARK: - Enums
    
  private var wasEdited = false
    
    @IBOutlet private weak var postDescription: UITextView!
    @IBOutlet private weak var timeStamp: UILabel!
    @IBOutlet private weak var authorName: UILabel!
    @IBOutlet private weak var changeTitleTextField: UITextField!
    @IBOutlet private weak var postTitleLabel: UILabel!
    
    var postRepresentation: PostRepresentation?
    var post: Post?
    var backendController: BackendController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
 navigationItem.rightBarButtonItem = editButtonItem
       updateViews()
    }
    
    @IBAction func likesButtonPressed(_ sender: UIButton) {
//        var likes = []
//        if sender.isSelected {
//        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        if editing { wasEdited = true }
        postDescription.isUserInteractionEnabled = editing
        changeTitleTextField.isUserInteractionEnabled = editing
    }
    
    private func updateViews() {
       
        guard let post = post,
            let title = changeTitleTextField.text,
            !title.isEmpty,
            let postBody = postDescription.text,
            !postBody.isEmpty
            else { return }
        if changeTitleTextField.isUserInteractionEnabled && postDescription.isUserInteractionEnabled == isEditing {
        backendController?.updatePost(at: post, title: title, post: postBody, completion: { error in
            if let error = error {
                NSLog("Error in updating the post")
            } else {
                
            }
        })
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
