//
//  ColorVC.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/21.
//  Copyright © 2017年 yyh. All rights reserved.
//

import UIKit

class ColorVC: UIViewController {
    
    var username: String?
    
    var model: String?
    
    var color: String?
    
    var ip: String?

    @IBAction func black(sender: AnyObject) {
        color = "black"
    }
    
    @IBAction func white(sender: AnyObject) {
        color = "white"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? BlackVC {
            destination.username = username
            destination.model = model
            if model == "single" {
                destination.view.userInteractionEnabled = true
            }
            destination.color = color
            destination.black = Black(username: username!)
            destination.ip = ip
        } else if let destination = segue.destinationViewController as? WhiteVC {
            destination.username = username
            destination.model = model
            destination.color = color
            destination.white = White(username: username!)
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
