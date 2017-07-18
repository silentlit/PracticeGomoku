//
//  ClientVC.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/18.
//  Copyright © 2017年 yyh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ClientVC: UIViewController
{    
    var clientSocket: GCDAsyncSocket?

    @IBOutlet weak var clientIP: UITextField!
    
    @IBOutlet weak var clientPort: UITextField!
    
    @IBOutlet weak var clientMsg: UITextField!
    
    @IBOutlet weak var clientReceivedMsg: UITextView!
    
    //显示提示 消息
    func addText(t: String) {
        clientReceivedMsg.text = clientReceivedMsg.text.stringByAppendingFormat("%@\n", t)
    }
    
    //建立连接
    @IBAction func connect(sender: AnyObject) {
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try clientSocket?.connectToHost(clientIP.text!, onPort: UInt16(clientPort.text!)!)
            addText("Success")
            
        } catch _ {
            addText("Failed")
        }
    }
    
    //断开连接
    @IBAction func disconnect(sender: AnyObject) {
        clientSocket?.disconnect()
        addText("DisConnected")
    }
    
    //发送消息
    @IBAction func sendMsg(sender: AnyObject) {
        clientSocket?.writeData((clientMsg.text?.dataUsingEncoding(NSUTF8StringEncoding))!, withTimeout: -1, tag: 0)
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

extension ClientVC: GCDAsyncSocketDelegate {
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        addText("Connect to server " + host)
        clientSocket?.readDataWithTimeout(-1, tag: 0)
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        if let msg = String(data: data, encoding: NSUTF8StringEncoding) {
            addText(msg)
            clientSocket?.readDataWithTimeout(-1, tag: 0)
        }
    }
}
