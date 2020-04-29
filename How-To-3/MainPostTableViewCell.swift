//
//  MainPostTableViewCell.swift
//  How-To-3
//
//  Created by Bhawnish Kumar on 4/28/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import CoreData
class MainPostTableViewCell: UITableViewCell {
   
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
  
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    var backendController: BackendController?
    var postRepresentation: PostRepresentation?
    
    
    private func updateViews() {
        guard let post = post else { return }
        postTitleLabel.text = post.title
        authorNameLabel.text = String(post.userID)
        timeStampLabel.text = post.timestamp

        
    }

}
