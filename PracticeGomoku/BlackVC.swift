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
    var clientSocket: GCDAsyncSocket? //黑
    
    var black: Chess?
    
    var username: String?
    var model: String?
    var color: String?
    var ip: String?
    
    var redDot = UIImageView()
    
    var blackCalcFunc: Calc!
    var whiteCalcFunc: Calc!
    
    //棋盘
    @IBOutlet weak var blackChessBoard: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        black = Chess(c: Color.black, username: username!)
        color = "black"
        
        if model == "multi" {
            self.view.userInteractionEnabled = false
        }
        
        
        blackCalcFunc = Calc(tapPoint: CGPoint(), frameOfSelfView: self.view.frame)
        whiteCalcFunc = Calc(tapPoint: CGPoint(), frameOfSelfView: self.view.frame)
        
//        blackCalcFunc = Calc(tapPoint: CGPoint(), frameOfSelfView: self.view.frame)
//        let temCalc = Calc(tapPoint: CGPoint(), frameOfSelfView: self.view.frame)
//        let chessboardWidth = temCalc.chessboardWidth
//        blackChessBoard.bounds.size = CGSize(width: chessboardWidth, height: chessboardWidth)
        // Do any additional setup after loading the view.
        
        //开始连接
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try clientSocket?.connectToHost(ip!, onPort: UInt16(1234))
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
    @IBAction func tapChessboard(sender: UIGestureRecognizer) {
        let location: CGPoint = sender.locationInView(self.view) //tap的真实坐标
        blackCalcFunc = Calc(tapPoint: location, frameOfSelfView: self.view.frame) //初始化计算
        let formatLocation = blackCalcFunc.absLocationTransformToRealLocation(false) //获取tap规范化后坐标
        
        //检验落子合法性
        if black?.isLegalOrNot(blackCalcFunc.absLocation) == false {
            return
        }
        
//        print(calcFunc.tapLocation, calcFunc.absLocation)
        
        //将棋子添加到棋盘上
        let blackChess = UIImageView()
        let chessWidth = blackCalcFunc.chessWidth
        blackChess.frame = CGRectMake(formatLocation.x, formatLocation.y, chessWidth, chessWidth)
        blackChess.image = UIImage(named: "black")
        blackChess.image?.accessibilityIdentifier = "black"
        self.view.addSubview(blackChess)
        
        //绘制当前点
        drawRedDot(formatLocation, chessWidth: chessWidth)
        
        //落子完成设置为不可交互
        self.view.userInteractionEnabled = false
        
        //添加棋子到抽象棋盘上
        black?.addChess(blackCalcFunc.absLocation, chess: blackChess)
        
        //落子位置发送给白子
        sendMsgToServer("drawBlack,\(blackCalcFunc.absLocation.x),\(blackCalcFunc.absLocation.y)")
        
        //胜负
        if didIWin() == true {
            sendMsgToServer("blackWin")
            let alert = UIAlertView()
            alert.title = "You Win"
            alert.message = "game over"
            alert.addButtonWithTitle("Done")
            alert.show()
            self.view.userInteractionEnabled = false
        }
    }
    
    //绘制红点表明最新的落子位置
    func drawRedDot(formartLocation: CGPoint, chessWidth: CGFloat) {
        redDot.removeFromSuperview()
        let x = formartLocation.x + chessWidth / 2.4
        let y = formartLocation.y + chessWidth / 2.4
        redDot.frame = CGRectMake(x, y, chessWidth / 5.5, chessWidth / 5.5)
        redDot.image = UIImage(named: "redDot")
        self.view.addSubview(redDot)
    }
    
    //胜负判定
    func didIWin() -> Bool {
        return (black?.didWinOrNot(blackCalcFunc.absLocation, color: color!))!
    }
    
    //将信息发送给client
    func sendMsgToServer(msg: String) {
//        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
//        
//        do {
//            try clientSocket?.connectToHost("172.168.70.47", onPort: UInt16(1234))
//            print("Client connect Success")
//            
//        } catch _ {
//            print("Client connect Failed")
//        }
        
        if let data = msg.dataUsingEncoding(NSUTF8StringEncoding) {
            clientSocket?.writeData(data, withTimeout: -1, tag: 0)
        }
//        clientSocket?.disconnect()
//        clientSocket = nil
    }
    
    //画白子
    func drawWhite() {
        let whiteChess = UIImageView()
        let chessWidth = whiteCalcFunc.chessWidth
        let formatLocation = whiteCalcFunc.absLocationTransformToRealLocation(true)
        
        whiteChess.frame = CGRectMake(formatLocation.x, formatLocation.y, chessWidth, chessWidth)
        whiteChess.image = UIImage(named: "white")
        self.view.addSubview(whiteChess)
        self.view.userInteractionEnabled = true
        
        drawRedDot(formatLocation, chessWidth: chessWidth)
        
        black?.addChess(whiteCalcFunc.absLocation, chess: whiteChess)
    }
    
    //白棋胜利
    func whiteWin() {
        let alert = UIAlertView()
        alert.title = "You Lose"
        alert.message = "game over"
        alert.addButtonWithTitle("Done")
        alert.show()
        self.view.userInteractionEnabled = false
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
    //建立连接后
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        whiteCalcFunc = Calc(tapPoint: CGPoint(), frameOfSelfView: self.view.frame)
        print("Connect to server " + host)
        clientSocket?.readDataWithTimeout(-1, tag: 0)
        sendMsgToServer("username,b\(username!)")
    }
    
    //读取server消息
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        if let msg = String(data: data, encoding: NSUTF8StringEncoding) {
            let info = msg.componentsSeparatedByString(",")
            let condition = info.first ?? ""
            
            //根据condition选择功能
            switch condition {
            case "drawWhite": //画黑子
                whiteCalcFunc.absLocation.x = Int(info[1])!
                whiteCalcFunc.absLocation.y = Int(info[2])!
                drawWhite()
                
            case "blackEnable":
                self.view.userInteractionEnabled = true
                
            case "whiteWin":
                whiteWin()
                
            default:
                break
            }
            
            clientSocket?.readDataWithTimeout(-1, tag: 0)
        }
    }
}
