//
//  InterViewController.swift
//  How-To-3
//
//  Created by Bhawnish Kumar on 4/30/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit

class InterViewController: UIViewController, PostPresenter {

    // MARK: - Properties

    // MARK: - Outlets

    // MARK: - Protocol Conforming

    // MARK: - Custom Methods

    // MARK: - Enums
    
    func postWasSelected(post: Post) {
        print(post)
    }
    

     override func viewDidLoad() {
         super.viewDidLoad()

         // Do any additional setup after loading the view.
     }
     

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
            if segue.identifier == "PostsTable" {
             guard let backendController = backendController else { return }
                guard let postsTVC = segue.destination as? MainPostTableViewController else { return }
                
                postsTVC.backendController = backendController
                
                mainPostTableViewController = postsTVC
            }
            
        }
        
        var mainPostTableViewController: MainPostTableViewController?
        
        var backendController: BackendController?
}
