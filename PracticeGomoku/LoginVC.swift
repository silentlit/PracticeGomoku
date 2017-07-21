//
//  LoginVC.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/21.
//  Copyright © 2017年 yyh. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    var username: String?

    @IBAction func login(sender: AnyObject) {
        username = usernameTextField.text ?? "default:\(random())"
        if username == "" {
            username = "default:\(random())"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? ModelVC {
            destination.username = username
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
