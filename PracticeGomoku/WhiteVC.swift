//
//  WhiteVC.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/19.
//  Copyright © 2017年 yyh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class WhiteVC: UIViewController
{
    var clientSocket: GCDAsyncSocket?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //开始连接
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try clientSocket?.connectToHost("127.0.0.1", onPort: UInt16(1234))
            print("Success")
            
        } catch _ {
            print("Failed")
        }
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

extension WhiteVC: GCDAsyncSocketDelegate {
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Connect to server " + host)
        clientSocket?.readDataWithTimeout(-1, tag: 0)
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        if let msg = String(data: data, encoding: NSUTF8StringEncoding) {
            print(msg)
            clientSocket?.readDataWithTimeout(-1, tag: 0)
        }
    }
}
