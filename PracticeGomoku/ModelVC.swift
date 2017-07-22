//
//  ModelVC.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/21.
//  Copyright © 2017年 yyh. All rights reserved.
//

import UIKit

class ModelVC: UIViewController {
    
    var username: String?
    
    var model: String?
    
    var ip: String?

    @IBAction func multi(sender: AnyObject) {
        model = "multi"
    }
    
    @IBAction func single(sender: AnyObject) {
        model = "single"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? ColorVC {
            destination.username = username
            destination.model = model
            destination.ip = ip
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
