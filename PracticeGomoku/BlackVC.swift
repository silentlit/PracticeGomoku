//
//  BlackVC.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/19.
//  Copyright © 2017年 yyh. All rights reserved.
//

import UIKit

class BlackVC: UIViewController
{
    //当前屏幕宽度
    var screenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.width
    }
    //当前屏幕高度
    var screenHeight: CGFloat {
        return UIScreen.mainScreen().bounds.height
    }
    //计算棋盘的大小
    var chessboardWidth: CGFloat {
        return min(screenWidth, screenHeight)
    }
    //计算棋子大小
    var chessWidth: CGFloat {
        return chessboardWidth / 17 //魔数
    }
    //计算缩放比例
    var scale: Double {
        return (Double(chessboardWidth) / 535) //535为棋盘素材大小
    }
    //计算留白大小
    var blankWidth: CGFloat {
        return CGFloat(22) * CGFloat(scale) //22为棋盘素材留白大小
    }
    //计算网格大小
    var squareWidth: CGFloat {
        return (CGFloat(535) * CGFloat(scale) - 2 * blankWidth) / 14 //14格
    }
    //计算棋子之间的间距
    var chessBy: CGFloat {
        return squareWidth - chessWidth
    }

    //棋盘
    @IBOutlet weak var blackChessBoard: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blackChessBoard.bounds.size = CGSize(width: chessboardWidth, height: chessboardWidth)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //落子
    @IBAction func tapChessboard(sender: UIGestureRecognizer) {
        let location: CGPoint = sender.locationInView(self.view) //tap的真实坐标
        let absLocation: CGPoint = CGPoint(calculateChessAbsLocation(location))//抽象棋盘的坐标
        print("\(location)->\(absLocation)")
        
        //计算出 真实棋盘坐标 = f(抽象坐标)
        let x = blankWidth + (absLocation.x - 1) * squareWidth - chessWidth / 2
        let y = self.view.frame.midY - (8 - absLocation.y) * squareWidth - chessWidth / 2
        print((x, y))
        
        //将棋子添加到棋盘上
        let blackChess = UIImageView()
        blackChess.frame = CGRectMake(x, y, chessWidth, chessWidth)
        blackChess.image = UIImage(named: "black")
        self.view.addSubview(blackChess)
    }
    
    //计算抽象的落子位置
    func calculateChessAbsLocation(location: CGPoint) -> (x: Int, y: Int) {
        let x: Int = 8 + Int((location.x - self.view.frame.midX) / chessWidth)
        let y: Int = 8 + Int((location.y - self.view.frame.midY) / chessWidth)
        return (x, y)
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
