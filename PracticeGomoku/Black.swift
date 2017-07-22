//
//  Black.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/18.
//  Copyright © 2017年 yyh. All rights reserved.
//

import Foundation

class Black: Chess
{
//    var chessStack = [[String: Black]]() //[x,y -> Black] 悔棋
    
    init(username: String) {
        super.init(c: Color.black, username: "b\(username)")
    }
    
//    //向栈中添加棋子 悔棋可以pop处理，向字典中加入棋子 检测可以直接point得到
//    func addChess(point: (x: Int, y: Int), chess: Black) {
//        let pointOfString = pointToString(point)
//        chessStack.append([pointOfString: chess])
//        location[pointOfString] = chess
//    }
//    
//    //将点坐标规范为String
//    func pointToString(point: (x: Int, y: Int)) -> String {
//        return "\(point.x),\(point.y)"
//    }
//    
//    //将String转化为point
//    func stringToPoint(pointOfString: String) -> (x: Int, y: Int) {
//        var info = pointOfString.componentsSeparatedByString(",")
//        let x = Int(info.removeFirst())!
//        let y = Int(info.removeFirst())!
//        
//        return (x, y)
//    }
    
}
