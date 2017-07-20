//
//  CalculateFuncs.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/20.
//  Copyright © 2017年 yyh. All rights reserved.
//

import Foundation
import UIKit

struct Calc {
    var _tapLocation: CGPoint //点击的位置
    var tapLocation: CGPoint {
        get {
            return self._tapLocation
        }
        set {
            _tapLocation = newValue
        }
    }
    
    var _absLocation: (x: Int, y: Int) //棋子抽象的位置
    var absLocation: (x: Int, y: Int) {
        get {
            return self._absLocation
        }
        set {
            _absLocation = newValue
        }
    }
    
    let frameOfView: CGRect //获取view的frame
    
    //当前屏幕宽度
    var screenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.width
    }//当前屏幕高度
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
    
    //初始化
    init(tapPoint: CGPoint, frameOfSelfView: CGRect) {
        _tapLocation = tapPoint
        frameOfView = frameOfSelfView
        _absLocation = (0, 0)
    }
    
    //计算抽象的落子位置
    mutating func calculateChessAbsLocation() -> CGPoint {
        let x: Int = 8 + Int((tapLocation.x - frameOfView.midX) / chessWidth)
        let y: Int = 8 + Int((tapLocation.y - frameOfView.midY) / chessWidth)
        absLocation = (x, y)
        return CGPoint(x: x, y: y)
    }
    
    //计算出 真实棋盘坐标 = f(抽象坐标)
    mutating func absLocationTransformToRealLocation() -> CGPoint {
        let absL = calculateChessAbsLocation() 
        let x = blankWidth + (absL.x - 1) * squareWidth - chessWidth / 2
        let y = frameOfView.midY - (8 - absL.y) * squareWidth - chessWidth / 2
        return CGPoint(x: x, y: y)
    }
}
