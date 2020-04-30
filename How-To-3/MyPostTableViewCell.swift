//
//  MyPostTableViewCell.swift
//  How-To-3
//
//  Created by Bhawnish Kumar on 4/28/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import CoreData
class MyPostTableViewCell: UITableViewCell {

    var backendController: BackendController?
    var post: Post?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateViews() {
        
        guard let backendController = backendController,
            let title = titleLabel.text,
            let author = post?.userID,
            let time = post?.timestamp,
            let bodyPost = post?.post,
            let id = post?.id
        else { return }
    
        backendController.createPost(title: title, post: bodyPost) { error in
            if error != nil {
                NSLog("Could not load posts")
                return
            }
            DispatchQueue.main.async {
            
            
            let newPost = Post(id: id, post: bodyPost, timestamp: time, title: title, userID: author)
                
                backendController.userPosts.append(newPost)
            }
        }
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("error in loading post")
            return
        }
    }
}
