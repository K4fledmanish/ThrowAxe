//
//  StartViewController.swift
//  ThrowAxe
//
//  Created by Hoang Hiep Nguyen on 20/9/18.
//  Copyright © 2018 Group 2. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // link the start button to the main game view
    @IBAction func playButton(_ sender: Any) {
        performSegue(withIdentifier: "startToMainSegue", sender: self)
    }
    
    @IBOutlet weak var topScoreLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let gameScore = defaults.value(forKey: "score"){
            let score = gameScore as! Int
            topScoreLabel.text = "Your Score: \(String(score))"
        }
    }
}
