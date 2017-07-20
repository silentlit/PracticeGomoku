//
//  BlackVC.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/19.
//  Copyright © 2017年 yyh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class BlackVC: UIViewController
{
    var serverSocket: GCDAsyncSocket?
    var clientSocket: GCDAsyncSocket?
    
    //棋盘
    @IBOutlet weak var blackChessBoard: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let temCalc = Calc(tapPoint: CGPoint(), frameOfSelfView: self.view.frame)
        let chessboardWidth = temCalc.chessboardWidth
        blackChessBoard.bounds.size = CGSize(width: chessboardWidth, height: chessboardWidth)
        // Do any additional setup after loading the view.
        
        //开始监听
        serverSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try serverSocket?.acceptOnPort(UInt16(1234))
            print("Success")
        } catch _ {
            print("Failed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //落子
    @IBAction func tapChessboard(sender: UIGestureRecognizer) {
        let location: CGPoint = sender.locationInView(self.view) //tap的真实坐标
        var calcFunc = Calc(tapPoint: location, frameOfSelfView: self.view.frame) //初始化计算
        let formatLocation = calcFunc.absLocationTransformToRealLocation() //获取tap规范化后坐标
        
        print(calcFunc.tapLocation, calcFunc.absLocation)
        
        //将棋子添加到棋盘上
        let blackChess = UIImageView()
        let chessWidth = calcFunc.chessWidth
        blackChess.frame = CGRectMake(formatLocation.x, formatLocation.y, chessWidth, chessWidth)
        blackChess.image = UIImage(named: "black")
        self.view.addSubview(blackChess)
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

extension BlackVC: GCDAsyncSocketDelegate {
    //接收到新的socket连接时执行
    func socket(sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("Connect succeed")
        if let h = newSocket.connectedHost {
            print("Host: " + String(h))
            print("Port: " + String(newSocket.connectedPort))
        }
        
        //第一次读取data
        clientSocket = newSocket
        clientSocket?.readDataWithTimeout(-1, tag: 0)
    }
    
    //再次读取data
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        if let msg = String.init(data: data, encoding: NSUTF8StringEncoding) {
            print(msg)
            
            //循环读取
            sock.readDataWithTimeout(-1, tag: 0)
        }
    }
}
