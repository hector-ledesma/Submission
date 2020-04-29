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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    var backendController: BackendController?

    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        if let title = postDescription.text {

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
