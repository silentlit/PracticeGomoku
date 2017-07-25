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
        
        // Do any additional setup after loading the view.
        
        //开始连接
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try clientSocket?.connectToHost("172.168.70.73", onPort: UInt16(1234))
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
        drawRedDot(formatLocation, chessWidth: chessWidth, chess: blackChess)
        
        //落子完成设置为不可交互
        self.view.userInteractionEnabled = false
        
        //添加棋子到抽象棋盘上
//        black?.addChess(blackCalcFunc.absLocation, chess: blackChess)
        
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
    func drawRedDot(formartLocation: CGPoint, chessWidth: CGFloat, chess: UIImageView) {
        redDot.removeFromSuperview()
        let x = formartLocation.x + chessWidth / 2.4
        let y = formartLocation.y + chessWidth / 2.4
        redDot.frame = CGRectMake(x, y, chessWidth / 5.5, chessWidth / 5.5)
        redDot.image = UIImage(named: "redDot")
        self.view.addSubview(redDot)
        
        //添加落子位置[abs(x, y): chess] 以及 红点位置 redDotLocation到抽象棋盘中
        let absPoint = chess.image?.accessibilityIdentifier == "black" ? blackCalcFunc.absLocation: whiteCalcFunc.absLocation
        black?.addChess(absPoint, chess: chess, redDotLocation: CGPoint(x: x, y: y))
//        print(blackCalcFunc.absLocation)
    }
    func drawRedDot(origin: CGPoint) {
        let chessWidth = blackCalcFunc.chessWidth
        let x = origin.x + chessWidth / 2.4
        let y = origin.y + chessWidth / 2.4
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
        if let data = msg.dataUsingEncoding(NSUTF8StringEncoding) {
            clientSocket?.writeData(data, withTimeout: -1, tag: 0)
        }
    }
    
    //画白子
    func drawWhite() {
        let whiteChess = UIImageView()
        let chessWidth = whiteCalcFunc.chessWidth
        let formatLocation = whiteCalcFunc.absLocationTransformToRealLocation(true)
        
        whiteChess.frame = CGRectMake(formatLocation.x, formatLocation.y, chessWidth, chessWidth)
        whiteChess.image = UIImage(named: "white")
        whiteChess.image?.accessibilityIdentifier = "white"
        self.view.addSubview(whiteChess)
        self.view.userInteractionEnabled = true
        
        drawRedDot(formatLocation, chessWidth: chessWidth, chess: whiteChess)
        
//        black?.addChess(whiteCalcFunc.absLocation, chess: whiteChess)
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

    //悔棋 落子后悔棋出栈两次 落子前悔棋出栈三次 根据第一次出栈情况判定是否落子
    @IBAction func undo(sender: AnyObject) {
        sendMsgToServer("blackRequestUndo")
    }
    
    //自身发出悔棋请求通过
    func selfUndo() {
        if let firstPop = black?.popFromStack() { //(chess, chessAbsPointOfString)
            redDot.removeFromSuperview()
            firstPop.chess.removeFromSuperview()
            if firstPop.chess.image?.accessibilityIdentifier == "black" { //落子后
                if let secondPop = black?.popFromStack() {
                    secondPop.chess.removeFromSuperview()
                    let pointInfo = secondPop.chessAbsPointOfString.componentsSeparatedByString(",")
                    whiteCalcFunc.absLocation.x = Int(pointInfo[0])!
                    whiteCalcFunc.absLocation.y = Int(pointInfo[1])!
                    drawWhite()
                }
            } else if firstPop.chess.image?.accessibilityIdentifier == "white" { //落子前
                if let secondPop = black?.popFromStack() {
                    secondPop.chess.removeFromSuperview()
                    if let thirdPop = black?.popFromStack() {
                        thirdPop.chess.removeFromSuperview()
                        let pointInfo = thirdPop.chessAbsPointOfString.componentsSeparatedByString(",")
                        whiteCalcFunc.absLocation.x = Int(pointInfo[0])!
                        whiteCalcFunc.absLocation.y = Int(pointInfo[1])!
                        drawWhite()
                    }
                }
            }
        }
    }
    
    //dict -> drawRedDot
    func drawRedDotByDict(lastChessDict: [String : UIImageView]) {
        let keys = Array(lastChessDict.keys)
        let key = keys.first!
        let chess = lastChessDict[key]!
        let origin = chess.frame.origin
        drawRedDot(origin)
    }
    
    //对方发出悔棋请求通过
    func whiteUndo() {
        self.view.userInteractionEnabled = false
        if let firstPop = black?.popFromStack() {
            redDot.removeFromSuperview()
            firstPop.chess.removeFromSuperview()
            if firstPop.chess.image?.accessibilityIdentifier == "black" { //落子后
                if let secondPop = black?.popFromStack() {
                    secondPop.chess.removeFromSuperview()
                    if let lastChessDict = black?.chessStack.last {
                        drawRedDotByDict(lastChessDict)
                    }
                }
            } else if firstPop.chess.image?.accessibilityIdentifier == "white" { //落子前
                if let lastChessDict = black?.chessStack.last {
                    drawRedDotByDict(lastChessDict)
                }
            }
        }
    }
    
    //处理对方请求
    func reqsCommitOrNot() {
        let alertVC = UIAlertController(title: "白子提出悔棋请求", message: "", preferredStyle: .Alert)
        alertVC.addAction(UIAlertAction(title: "commit", style: UIAlertActionStyle.Default, handler: { action in
            self.sendMsgToServer("blackCommit")
            self.whiteUndo() }))
        alertVC.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertVC, animated: true, completion: nil)
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
            case "drawWhite" : //画黑子
                whiteCalcFunc.absLocation.x = Int(info[1])!
                whiteCalcFunc.absLocation.y = Int(info[2])!
                drawWhite()
                
            case "blackEnable" :
                self.view.userInteractionEnabled = true
                
            case "whiteWin" :
                whiteWin()
                
            case "whiteRequestUndo" :
                reqsCommitOrNot()
                if black?.chessStack.isEmpty == true {
                    self.view.userInteractionEnabled = true
                }
                
            case "whiteCommit" :
                selfUndo()
                
            default:
                break
            }
            
            clientSocket?.readDataWithTimeout(-1, tag: 0)
        }
    }
}
