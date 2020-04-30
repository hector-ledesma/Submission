//
//  MainPostViewController.swift
//  How-To-3
//
//  Created by Bhawnish Kumar on 4/29/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit

class AllPostsTabBarController: UITabBarController {

    // MARK: - Properties

    // MARK: - Outlets

    // MARK: - Protocol Conforming

    // MARK: - Custom Methods

    // MARK: - Enums
    

    var backendController = BackendController.shared
    
    override func viewDidLoad() {
           super.viewDidLoad()

           // Pass the place controller to the child view controllers (the relationship view controllers)
           
        for childVC in children {
               // If the child view controller conforms to PlacesPresenter, we KNOW there is a placesController property that we can pass the places controller to.
               if let childVC = childVC as? PostPresenter {
                   childVC.backendController = backendController
               }
           }
       }
    
}
