//
//  ServerVC.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/18.
//  Copyright © 2017年 yyh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ServerVC: UIViewController
{
    var serverSocket: GCDAsyncSocket?
    var clientSocket: GCDAsyncSocket?

    @IBOutlet weak var serverPortText: UITextField!
    
    @IBOutlet weak var serverMsgText: UITextField!
    
    @IBOutlet weak var serverReceivedMsg: UITextView!
    
    //开始监听端口
    @IBAction func serverListen(sender: AnyObject) {
        serverSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try serverSocket?.acceptOnPort(UInt16(serverPortText.text!)!)
            addText("Success")
        } catch _ {
            addText("Failed")
        }
    }
    
    //服务端传出消息
    @IBAction func serverSend(sender: AnyObject) {
        if let data = serverMsgText.text?.dataUsingEncoding(NSUTF8StringEncoding) {
            clientSocket?.writeData(data, withTimeout: -1, tag: 0)
        }
    }
    
    //显示提示 消息
    func addText(t: String) {
        serverReceivedMsg.text = serverReceivedMsg.text.stringByAppendingFormat("%@\n", t)
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

extension ServerVC: GCDAsyncSocketDelegate {
    //接收到新的socket连接时执行
    func socket(sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        addText("Connect succeed")
        if let h = newSocket.connectedHost {
            addText("Host: " + String(h))
            addText("Port: " + String(newSocket.connectedPort))
        }
        
        //第一次读取data
        clientSocket = newSocket
        clientSocket?.readDataWithTimeout(-1, tag: 0)
    }
    
    //再次读取data
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        if let msg = String.init(data: data, encoding: NSUTF8StringEncoding) {
            addText(msg)
            
            //循环读取
            sock.readDataWithTimeout(-1, tag: 0)
        }
    }
}
