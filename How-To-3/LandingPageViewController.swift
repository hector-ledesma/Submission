//
//  LandingPageViewController.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/30/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit

class LandingPageViewController: UIViewController {

    @IBAction func landingUnwind(unwindSegue: UIStoryboardSegue) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension LandingPageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
