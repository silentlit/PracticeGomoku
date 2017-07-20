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
    var clientSocket: GCDAsyncSocket? //白子
    
    var blackCalcFunc: Calc!
    var whiteCalcFunc: Calc!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        blackCalcFunc = Calc(tapPoint: CGPoint(), frameOfSelfView: self.view.frame)
        whiteCalcFunc = Calc(tapPoint: CGPoint(), frameOfSelfView: self.view.frame)

        // Do any additional setup after loading the view.
        
        //开始连接
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try clientSocket?.connectToHost("127.0.0.1", onPort: UInt16(1234))
            print("Client connect Success")
            
        } catch _ {
            print("Client connect Failed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //落子
    @IBAction func tapChessboard(sender: UITapGestureRecognizer) {
        let location: CGPoint = sender.locationInView(self.view) //tap的真实坐标
        whiteCalcFunc = Calc(tapPoint: location, frameOfSelfView: self.view.frame) //初始化计算
        let formatLocation = whiteCalcFunc.absLocationTransformToRealLocation(false) //获取tap规范化后坐标
        
        //将棋子添加到棋盘上
        let whiteChess = UIImageView()
        let chessWidth = whiteCalcFunc.chessWidth
        whiteChess.frame = CGRectMake(formatLocation.x, formatLocation.y, chessWidth, chessWidth)
        whiteChess.image = UIImage(named: "white")
        self.view.addSubview(whiteChess)
        
        //落子位置发送给黑子
        sendMsgToServer("drawWhite,\(whiteCalcFunc.absLocation.x),\(whiteCalcFunc.absLocation.y)")
    }
    
    //将黑子画出来
    func drawBlack() {
//        print(blackCalcFunc.absLocation)
        let blackChess = UIImageView()
        let chessWidth = blackCalcFunc.chessWidth
        let formatLocation = blackCalcFunc.absLocationTransformToRealLocation(true)
        
//        print(formatLocation)
        blackChess.frame = CGRectMake(formatLocation.x, formatLocation.y, chessWidth, chessWidth)
        blackChess.image = UIImage(named: "black")
        self.view.addSubview(blackChess)
    }
    
    //消息发送给server
    func sendMsgToServer(msg: String) {
        if let data = msg.dataUsingEncoding(NSUTF8StringEncoding) {
            clientSocket?.writeData(data, withTimeout: -1, tag: 0)
        }
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
    //建立连接后
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        blackCalcFunc = Calc(tapPoint: CGPoint(), frameOfSelfView: self.view.frame)
        print("Connect to server " + host)
        clientSocket?.readDataWithTimeout(-1, tag: 0)
    }
    
    //读取server消息
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        if let msg = String(data: data, encoding: NSUTF8StringEncoding) {
            let info = msg.componentsSeparatedByString(",")
            let condition = info.first ?? ""
            
            //根据condition选择功能
            switch condition {
            case "drawBlack": //画黑子
                blackCalcFunc.absLocation.x = Int(info[1])!
                blackCalcFunc.absLocation.y = Int(info[2])!
                drawBlack()
                
            default:
                break
            }
            
            clientSocket?.readDataWithTimeout(-1, tag: 0)
        }
    }
}
