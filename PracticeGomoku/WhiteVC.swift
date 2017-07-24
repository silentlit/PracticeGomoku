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
    var clientSocket: GCDAsyncSocket? //白
    
    var white: Chess?
    
    var username: String?
    var model: String?
    var color: String?
    var ip: String?
    
    var redDot = UIImageView()
    
    var blackCalcFunc: Calc!
    var whiteCalcFunc: Calc!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.userInteractionEnabled = false
        white = Chess(c: Color.white, username: username!)
        color = "white"
        
        blackCalcFunc = Calc(tapPoint: CGPoint(), frameOfSelfView: self.view.frame)
        whiteCalcFunc = Calc(tapPoint: CGPoint(), frameOfSelfView: self.view.frame)

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
    @IBAction func tapChessboard(sender: UITapGestureRecognizer) {
        let location: CGPoint = sender.locationInView(self.view) //tap的真实坐标
        whiteCalcFunc = Calc(tapPoint: location, frameOfSelfView: self.view.frame) //初始化计算
        let formatLocation = whiteCalcFunc.absLocationTransformToRealLocation(false) //获取tap规范化后坐标
        
        //检验落子合法性
        if white?.isLegalOrNot(whiteCalcFunc.absLocation) == false {
            return
        }
        
        //将棋子添加到棋盘上
        let whiteChess = UIImageView()
        let chessWidth = whiteCalcFunc.chessWidth
        whiteChess.frame = CGRectMake(formatLocation.x, formatLocation.y, chessWidth, chessWidth)
        whiteChess.image = UIImage(named: "white")
        whiteChess.image?.accessibilityIdentifier = "white"
        self.view.addSubview(whiteChess)
        
        //绘制当前点
        drawRedDot(formatLocation, chessWidth: chessWidth, chess: whiteChess)
        
        //落子完成设置为不可交互
        self.view.userInteractionEnabled = false
        
        //添加棋子到抽象棋盘上
//        white?.addChess(whiteCalcFunc.absLocation, chess: whiteChess)
        
        //落子位置发送给黑子
        sendMsgToServer("drawWhite,\(whiteCalcFunc.absLocation.x),\(whiteCalcFunc.absLocation.y)")
        
        //胜负
        if didIWin() == true {
            sendMsgToServer("whiteWin")
            let alert = UIAlertView()
            alert.title = "You Win"
            alert.message = "game over"
            alert.addButtonWithTitle("Done")
            alert.show()
            self.view.userInteractionEnabled = false
        }
    }
    
    //绘制红点表明最新的落子位置
    func drawRedDot(formartLocation: CGPoint, chessWidth: CGFloat, chess: UIImageView) {
        redDot.removeFromSuperview()
        let x = formartLocation.x + chessWidth / 2.4
        let y = formartLocation.y + chessWidth / 2.4
        redDot.frame = CGRectMake(x, y, chessWidth / 5.5, chessWidth / 5.5)
        redDot.image = UIImage(named: "redDot")
        self.view.addSubview(redDot)
        
        //添加落子位置[abs(x, y): chess] 以及 红点位置 redDotLocation到抽象棋盘中
        let absPoint = chess.image?.accessibilityIdentifier == "black" ? blackCalcFunc.absLocation: whiteCalcFunc.absLocation
        white?.addChess(absPoint, chess: chess, redDotLocation: CGPoint(x: x, y: y))
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
        blackChess.image?.accessibilityIdentifier = "black"
        self.view.addSubview(blackChess)
        self.view.userInteractionEnabled = true
        
        drawRedDot(formatLocation, chessWidth: chessWidth, chess: blackChess)
        
//        white?.addChess(blackCalcFunc.absLocation, chess: blackChess)
    }
    
    //胜负判定
    func didIWin() -> Bool {
        return (white?.didWinOrNot(whiteCalcFunc.absLocation, color: color!))!
    }
    
    //消息发送给server
    func sendMsgToServer(msg: String) {
//        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
//        
//        do {
//            try clientSocket?.connectToHost("127.0.0.1", onPort: UInt16(1234))
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
    
    //黑棋胜利
    func blackWin() {
        let alert = UIAlertView()
        alert.title = "You Lose"
        alert.message = "game over"
        alert.addButtonWithTitle("Done")
        alert.show()
        self.view.userInteractionEnabled = false
    }

    //悔棋
    @IBAction func undo(sender: AnyObject) {
        if let firstPop = white?.popFromStack() { //(chess, chessAbsPointOfString)
            redDot.removeFromSuperview()
            firstPop.chess.removeFromSuperview()
            if firstPop.chess.image?.accessibilityIdentifier == "white" { //落子后
                if let secondPop = white?.popFromStack() {
                    secondPop.chess.removeFromSuperview()
                    let pointInfo = secondPop.chessAbsPointOfString.componentsSeparatedByString(",")
                    blackCalcFunc.absLocation.x = Int(pointInfo[0])!
                    blackCalcFunc.absLocation.y = Int(pointInfo[1])!
                    drawBlack()
                }
            } else if firstPop.chess.image?.accessibilityIdentifier == "black" { //落子前
                if let secondPop = white?.popFromStack() {
                    secondPop.chess.removeFromSuperview()
                    if let thirdPop = white?.popFromStack() {
                        thirdPop.chess.removeFromSuperview()
                        let pointInfo = thirdPop.chessAbsPointOfString.componentsSeparatedByString(",")
                        blackCalcFunc.absLocation.x = Int(pointInfo[0])!
                        blackCalcFunc.absLocation.y = Int(pointInfo[1])!
                        drawBlack()
                    }
                }
            }
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
        sendMsgToServer("username,w\(username!)")
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
                
            case "whiteEnable":
                self.view.userInteractionEnabled = true
                
            case "blackWin":
                blackWin()
                
            default:
                break
            }
//            clientSocket?.disconnect()
            clientSocket?.readDataWithTimeout(-1, tag: 0)
        }
    }
}
