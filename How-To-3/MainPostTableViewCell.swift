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
    
  
    var post: Post?
    var backendController: BackendController?
    var postRepresentation: PostRepresentation? {
        didSet {
            updateViews()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private func updateViews() {
        guard let postRepresentation = postRepresentation else { return }
    
        postTitleLabel.text = postRepresentation.title
        authorNameLabel.text = String(postRepresentation.userID)
        timeStampLabel.text = postRepresentation.timestamp

        
    }

}
