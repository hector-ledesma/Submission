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
   
    @IBOutlet private weak var postTitleLabel: UILabel!
    @IBOutlet private weak var likesLabel: UILabel!
    @IBOutlet private weak var authorNameLabel: UILabel!
    @IBOutlet private weak var timeStampLabel: UILabel!
    
  
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
